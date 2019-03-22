package dependencies

import change._
import utils._

/** Module to compute the dependencies of the `Change`. Permit to have
    the graph without an explicit construction. */
object Dependencies {
  /** Compute the dependencies of a `Change` in a list of `Change`.
    *
    * @param c The `Change` whose the dependencies would be computed.
    * @param l The list of `Change`.
    */
  private def computeAffected(change: Change, l: List[Change]) =  {
    l.foreach { c =>
      if(c.depends_on(change)) {
        change.affecteds = c :: change.affecteds
        c.dependencies = change :: c.dependencies
      }
    }
  }

  /** Compute the dependencies of a list of `Change`.
    *
    * @param l The list of `Change`.
    */
  def compute(l: List[Change]) = {
    l.foreach(_.affecteds = Nil)
    l.foreach(computeAffected(_, l))
  }
}
