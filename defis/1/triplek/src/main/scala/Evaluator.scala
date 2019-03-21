package evaluator

import change._
import dependencies._
import scala.util.{Try}
import scala.collection.mutable.HashSet
import scala.concurrent.Await
import scala.concurrent.duration._
import java.util.concurrent.TimeUnit
import java.util.concurrent.TimeUnit._

import akka.actor._

case object Start
case object Finish

class EvaluationActor(
    l: List[Change],
    scheduler: ActorRef) extends Actor {
  def receive = {
    case Start =>
      l.foreach(_.evaluate)
      scheduler ! Finish
      context.stop(self)
  }
}

class SchedulerActor(var n: Int) extends Actor {
  def receive = {
    case Finish =>
      n -= 1
      if(n == 0) {
        context.stop(self)
        context.system.terminate()
      }
  }
}


object Evaluator {

  private def evaluateConnectedsComponents(L: List[List[Change]]) = {
    val system = ActorSystem("Evaluator")
    val scheduler =
      system.actorOf(Props(new SchedulerActor(L.length)), name = "scheduler")
    val actors =
      L.map { l =>
        val actor = system.actorOf(Props(new EvaluationActor(l, scheduler)))
        actor ! Start
        actor
      }
    Await.ready(system.whenTerminated, Duration.Inf)
  }

  def computeConnected(
      c: Change,
      viewed: HashSet[Change],
      result: List[Change]): List[Change] = {
    var r = result
    (c.dependencies ++ c.affecteds).foreach { c1 =>
      if(!viewed.contains(c1)) {
        viewed += c1
        r = computeConnected(c, viewed, c1::r)
      }
    }
    return r
  }

  def computeAllConnecteds(
      l: List[Change],
      viewed: HashSet[Change]): List[List[Change]] = l match {
    case Nil => Nil
    case c::t =>
      if(viewed.contains(c))
        return computeAllConnecteds(t, viewed)
      else {
        viewed += c
        val connected = computeConnected(c, viewed, List(c))
        return connected :: computeAllConnecteds(t, viewed)
      }
  }

  def evaluateChanges(l: List[Change]): Unit = {
    if(l.isEmpty)
      return
    l.foreach(_.init)

    /* Replace these two lines by
       l.foreach(_.evaluate)
       => no need Akka.
   */
    val L: List[List[Change]] = computeAllConnecteds(l, HashSet())
    evaluateConnectedsComponents(L)

    l.foreach { c =>
      c.hasChanged =
        (c.correct != c.oldCorrect) || (c.correct && (c.oldValue != c.v))
      c.oldCorrect = c.correct
      c.oldValue = c.v
    }
  }

}

object Modifier {

  private def removeChange(toDel: Change, l: List[Change]): List[Change]= {
    l.foreach { c =>
      c.affecteds = c.affecteds.filter(c1 => c1 != toDel)
    }
    l.filter(c => c != toDel)
  }

  private def addChange(c: Change, l: List[Change]): List[Change] = {
    l.find { c1 => c1.p.equals(c.p) } match {
      case None =>
        c::l
      case Some(oldC) => {
        c.oldValue = oldC.v
        c.oldCorrect = oldC.correct
        removeChange(oldC, c::l)
      }
    }
  }

  def applyNewChange(c: Change, l: List[Change]): List[Change] = {
    l.foreach(_.hasChanged = false)
    val newApplied: List[Change] = addChange(c, l)
    Dependencies.compute(newApplied)
    Evaluator.evaluateChanges(newApplied)
    return newApplied
  }

}
