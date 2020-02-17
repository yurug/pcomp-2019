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

/** A message for Akka (start evaluation of a list of commands). */
case object Start
/** A message for Akka (The evaluation of list of commands is finished). */
case object Finish

/** Akka actor to evaluate a list of formulae. The idea is that each of these
  * actor will evaluate a list of formulae which constitute a connected
  * components of the graph of the formulae.
  *
  * @contructor Creates an actor to evaluate a list of formulae.
  * @param l The list of formulae to evaluate.
  * @param scheduler The actor which monitors all the EvaluatorActor.
  *
*/
class EvaluationActor(
    l: List[Change],
    scheduler: ActorRef) extends Actor {

  /** Receiver of the actor. When receive the message Start, begins the
    * evaluation of the formulae, and after that, signals to the monitor
    * that if has finished.
    */
  def receive = {
    case Start =>
      l.foreach(_.evaluate)
      scheduler ! Finish
      context.stop(self)
  }
}


/** Akka actor which monitors all the EvaluationActor. When all of the
  * evaluations are terminated, it permits to stop the actor system.
  *
  * @contructor Creates the scheduler.
  * @param n The number of evaluations which have been launched.
  *
*/
class SchedulerActor(var n: Int) extends Actor {
  /** Receiver of the actor. When receive the message Finish, it means that
    * an evaluation is finished. When there is no more evaluation, stop
    * the actor system.
    */
  def receive = {
    case Finish =>
      n -= 1
      if(n == 0) {
        context.stop(self)
        context.system.terminate()
      }
  }
}

/** Module of evaluation. It evaluates the connected components concurently
   using Akka.
  */
object Evaluator {

  /** Evaluate a list of list of changes. Assume two changes of two different
      list are not dependant to use concurrency (hence, it can evaluate
      connected components safely).
    *
    * @param L the list of changes to evaluate.
    */
  private def evaluateConnectedComponents(L: List[List[Change]]) = {
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

  /** Compute recursively the connected component of a `Change`.
    *
    * @param c The change whose the connected component should be computed.
    * @param viewed The changes that have already been viewed.
    * @param result The part of the connected component currently computed.
    * @return The connected component of `c` as a list of `Change`.
    */
  private def computeConnectedComponent(
      c: Change,
      viewed: HashSet[Change],
      result: List[Change]): List[Change] = {
    var r = result
    (c.dependencies ++ c.affecteds).foreach { c1 =>
      if(!viewed.contains(c1)) {
        viewed += c1
        r = computeConnectedComponent(c1, viewed, c1::r)
      }
    }
    return r
  }

  /** Compute recursively all the connected components of a list of `Change`.
    *
    * @param l The list of `Change`.
    * @param viewed The changes that have already been viewed.
    * @return The connected components of `l` as a list of list of `Change`.
    */
  def computeAllConnecteds(
      l: List[Change],
      viewed: HashSet[Change]): List[List[Change]] = l match {
    case Nil => Nil
    case c::t =>
      if(viewed.contains(c))
        return computeAllConnecteds(t, viewed)
      else {
        viewed += c
        val connected = computeConnectedComponent(c, viewed, List(c))
        return connected :: computeAllConnecteds(t, viewed)
      }
  }

  /** Evaluate a list of `Change`. Particularly, propagate the BChange.
    *
    * @param l The list of `Change` to evaluae=te.
    */
  def evaluateChanges(l: List[Change]): Unit = {
    if(l.isEmpty)
      return
    l.foreach(_.init)

    /* Replace these two lines by
       l.foreach(_.evaluate)
       => no need Akka.
   */
    val L: List[List[Change]] = computeAllConnecteds(l, HashSet())
    evaluateConnectedComponents(L)

    l.foreach { c =>
      c.hasChanged =
        (c.correct != c.oldCorrect) || (c.correct && (c.oldValue != c.v))
      c.oldCorrect = c.correct
      c.oldValue = c.v
    }
  }

}

object Modifier {

  /** Remove a `Change` from a list of `Change` (in particular, update the
    *  dependencies).
    *
    * @param toDel The `Change` to remove.
    * @param l The list of `Change`.
    * @return The new list of `Change` (without `toDel`).
    */
  private def removeChange(toDel: Change, l: List[Change]): List[Change]= {
    l.foreach { c =>
      c.affecteds = c.affecteds.filter(c1 => c1 != toDel)
      c.dependencies = c.dependencies.filter(c1 => c1 != toDel)
    }
    l.filter(c => c != toDel)
  }

  /** Add a `Change` to a list of `Change`. If there was an other `Change` at
    * the same position, remove it.
    *
    * @param c The `Change` to add.
    * @param l The list of `Change`.
    * @return The new list of `Change` (with `c`).
    */
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

  /** Apply a new `Change`. As it could affects old changes, should re-evaluate
    * them (a total re-evaluation could be avoided, but with a less-readable
    * code).
    *
    * @param c: The new `Change`.
    * @param l The list of previous `Change`.
    * @return The new list of `Change` (`c` is in, andif there was a change
              at the same position than `c`, it has been removed).
    */
  def applyNewChange(c: Change, l: List[Change]): List[Change] = {
    l.foreach(_.hasChanged = false)
    val newApplied: List[Change] = addChange(c, l)
    Dependencies.compute(newApplied)
    Evaluator.evaluateChanges(newApplied)
    return newApplied
  }

}
