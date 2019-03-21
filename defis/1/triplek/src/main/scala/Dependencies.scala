package dependencies

import change._
import utils._

object Dependencies {
  def computeAffected(change: Change, l: List[Change]) =  {
    l.foreach { c =>
      if(c.depends_on(change)) {
        change.affecteds = c :: change.affecteds
        c.dependencies = change :: c.dependencies
      }
    }
  }

  def compute(l: List[Change]) = {
    l.foreach(_.affecteds = Nil)
    l.foreach(computeAffected(_, l))
  }
}
