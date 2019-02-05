package change

import scala.collection.mutable.HashMap

import utils._


abstract class Change(val p: Position, var v: Int) {

  var affecteds: List[Change] = List()
  var valueWithInitialA: Int = 0

  var hasChanged: Boolean = false
  var oldValue = -1
  var correct: Boolean = true
  var oldCorrect: Boolean = true
  var has_changed: Boolean = false

  override def toString: String = if(correct) s"${v}" else "P"
  def depends_on(c: Change): Boolean = false
  def propagate(c: Change, viewed: HashMap[Change, Boolean]): Unit = ()

  def evaluate = {
    var viewed: HashMap[Change, Boolean] =
      new HashMap[Change, Boolean]()  { override def default(key:Change) = false }

    viewed(this) = true
    affecteds.foreach { c => c.propagate(this, viewed) }
  }

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
        if(counted == c.v) v = v + 1
        else if(counted == c.oldValue) v = v - 1
      }
      affecteds.foreach { c1 =>
        if(c1.correct) {
          c1.propagate(this, viewed)
        }
      }
    }
  }
}

object Change {
  def sortByBlockPosition(l: Array[BChange]): Array[BChange] = {
    l.sortBy { c =>
      (c.b.bottomRight.x, c.b.bottomRight.y, c.b.topLeft.x, c.b.topLeft.y)
    }
  }

  def split(changes: List[Change]): (List[AChange], List[BChange]) = {
    val (la, lb): (List[Change], List[Change]) = changes.partition {
      case c: AChange => true
      case c: BChange => false
    }
    (la.map {case a: AChange => a}, lb.map {case b: BChange => b})
  }
}
