package evaluator

import change._
import dependencies._
import scala.util.{Try}

object Evaluator {

  def evaluateChanges(l: List[Change]) = {
    l.foreach(_.init)
    l.foreach(_.evaluate)
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
    l.find { c1 => c1.p.x == c.p.x && c1.p.y == c.p.y } match {
      case None =>
        c.oldValue = c.valueWithInitialA
        c::l
      case Some(oldC) => {
        c.oldValue = oldC.v
        c.oldCorrect = c.correct
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
