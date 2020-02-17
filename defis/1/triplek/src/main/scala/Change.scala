package change

import scala.collection.mutable.HashMap

import utils._


/** Abstract class to repreesent a change of a cell.
  *
  * @contructor Creates a new Change with a position and a value.
  * @param p The position of this `Change`.
  * @param y The value of the associated cell.
  */
abstract class Change(val p: Position, var v: Int) {

  var affecteds: List[Change] = List()
  var dependencies: List[Change] = List()
  var valueWithInitialA: Int = 0

  var hasChanged: Boolean = false
  var oldValue = -1
  var correct: Boolean = true
  var oldCorrect: Boolean = true
  var has_changed: Boolean = false

  /** toString methods (used by `println`, etc.).
    *
    * @return A `String` corresponding to the change value (or "P" if incorrect
    *         `Change`).
    */
  override def toString: String = if(correct) s"${v}" else "P"

  /** Checks if a `Change` can affect the current `Change` (it means that
    * it is a depedencies).
    *
    * @param c The `Change` to test.
    * @return `true` if `c` is a dependecies of the current `Change`.
    */

  def depends_on(c: Change): Boolean = false

  /** Propagate a `Change`.
    *
    * @param c The `Change` to propagate.
    * @return viewed A HashMap which permits to know to which `Change` it has
    *         already been propagated (a HashSet seems more reasonable?).
    */
  def propagate(c: Change, viewed: HashMap[Change, Boolean]): Unit = ()

  /** Evaluate the `Change`. */
  def evaluate = {
    var viewed: HashMap[Change, Boolean] =
      new HashMap[Change, Boolean]()  { override def default(key:Change) = false }

    viewed(this) = true
    affecteds.foreach { c => c.propagate(this, viewed) }
  }

  /** Propagate an error. Indeed, if you are not correct, all the `Changes` that
    * depend on you are also incorrect.
    *
    * @return viewed A HashMap which permits to know to which `Change` it has
    *         already been propagated (a HashSet seems more reasonable?).
    */
  def propagateError(viewed: HashMap[Change, Boolean]): Unit = {
    if(!viewed(this)) {
      if(correct) {
        correct = false
        has_changed = true
      }
      viewed(this) = true
      affecteds.foreach { c =>
        c.propagateError(viewed)
      }
    }
  }

  /** Init the `Change` (for evaluation). By default it is correct, and has
      as value it initial value with A.
    */
  def init: Unit = {
    hasChanged = false
    correct = true
    v = valueWithInitialA
  }

}


class AChange(pos: Position, value: Int) extends Change(pos, value) {
  def this(x: Int, y: Int, v: Int) = {
    this(new Position(x, y), v)
    valueWithInitialA = v
  }
}


class BChange(pos: Position, val b: Block, value: Int, val counted: Int)
extends Change(pos, value) {

  def this(x:Int, y:Int, r1:Int, c1:Int, r2:Int, c2:Int, v:Int, vc:Int) = {
    this(new Position(x, y), new Block(r1, c1, r2, c2), v, vc)
  }

  override def depends_on(c: Change): Boolean = {
    b.contains(c.p)
  }

  private def applyPropagation(c: Change): Int = {
    if(counted == c.v) {
      v = v + 1;
      return 1
    }
    else if(counted == c.oldValue) {
      v = v - 1
      return -1
    }
    return 0
  }

  override def propagate(c: Change, viewed: HashMap[Change, Boolean]): Unit = {
    if(viewed(this)) {
      if(correct) {
        hasChanged = true
        correct = false
      }
      var errPropagated: HashMap[Change, Boolean] =
        new HashMap[Change,Boolean]()  { override def default(key:Change) = false }
      errPropagated(this) = true

      affecteds.foreach { c1 => c1.propagateError(errPropagated) }
    }
    else {
      viewed(this) = true
      if(c.oldValue != c.v) {
        val n = applyPropagation(c)
        c match {
          case c: AChange => valueWithInitialA += n
          case _ => ()
        }
      }

      affecteds.foreach { c1 =>
        if(c1.correct) {
          c1.propagate(this, viewed)
        }
      }
    }
  }
}

/** Companion object of the class Object, to simulate class methods. */
object Change {

  /** Sort a list of `BChange` by block position (lexicographic order on
    * (top-left corner, bottom-right corner)).
    *
    * @param l The list of `BChange` to sort.
    * @return The sorted list.
    */
  def sortByBlockPosition(l: List[BChange]): List[BChange] = {
    l.sortBy { c =>
      (c.b.bottomRight.x, c.b.bottomRight.y, c.b.topLeft.x, c.b.topLeft.y)
    }
  }

  /** Split a list of `Change` into the `AChange` part and the `BChange` part.
    *
    * @param l The list of `Change` to split.
    * @return The list of `AChange` and the list of `BChange` present in `l`.
    */
  def split(changes: List[Change]): (List[AChange], List[BChange]) = {
    val (la, lb): (List[Change], List[Change]) = changes.partition {
      case c: AChange => true
      case c: BChange => false
    }
    (la.map {case a: AChange => a}, lb.map {case b: BChange => b})
  }
}
