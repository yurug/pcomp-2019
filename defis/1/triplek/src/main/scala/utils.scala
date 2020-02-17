package utils

import scala.math.Ordering.Implicits._
import scala.language.{reflectiveCalls}
import change._

/** Position on the sheet.
  * WARNING : its attribute x and y should in fact be the opposite ;
  * x corresponds to the row and y to the column while the row is the
  * vertical coordinate and the columnn the horizontal one.
  *
  * @contructor Creates a new Position with an abscissa and a ordinate.
  * @param x The row of this position.
  * @param y The colum of this position.
  *
*/
class Position(val x: Int, val y: Int) {
  override def toString = s"(${x}, ${y})"

  /** Compare to an other position
    *
    * @param other The position to which it should be compared
    * @return `true` if `other` is "before" the current position.
    */
  def >(other: Position): Boolean = (x, y) > (other.x, other.y)

  /** Compare to an other position
    *
    * @param other The position to which it should be compared
    * @return `true` if the two positions are equal.
    */
  def equals(other: Position): Boolean = x == other.x && y == other.y

  /** Compare to an other position
    *
    * @param other The position to which it should be compared
    * @return `true` if `other` is "ater" the current position.
    */
  def <(other: Position): Boolean = (x, y) < (other.x, other.y)
}

/** Block of cells on the sheet from a top-left corner to a bottom-right one.
  *
  * @contructor Creates a new blocl with two positions.
  * @param x The topLeft position of the block.
  * @param y The bottomRight position of the block.
  *
*/
class Block(val topLeft: Position, val bottomRight: Position) {

  /** Creates a new blocks from destructed positions.
    *
    * @param r1 The row of the topLeft position of the block.
    * @param c1 The column of the topLeft position of the block.
    * @param r2 The row of the bottomRight position of the block.
    * @param c2 The colum of the bottomRight position of the block.
    */
  def this(r1:Int, c1:Int, r2:Int, c2:Int) = {
    this(new Position(r1, c1), new Position(r2, c2))
  }

  /** Check if a position is in the block.
    *
    * @param position The position to check.
    * @return `true` if `position` is in the block.
    */
  def contains(position: Position): Boolean = {
    return position.x >= topLeft.x && position.x <= bottomRight.x &&
           position.y >= topLeft.y && position.y <= bottomRight.y
  }

  /** Check if the block is after such a position, that is to say the top-left
    * corner of the block is after the position.
    *
    * @param position The position to check.
    * @return `true` if the block is after `position`.
    */
  def isAfter(p: Position): Boolean = {
    topLeft > p
  }
}


/** Object to make the management of a resource easier. */
object Resource {
  /** Apply safely a function to a resource, and close the resource.
    *
    * @param resource The resource which should be treated.
    * @param f The function to apply to the resource.
    */
  def applyFunction[A <: { def close(): Unit }, B](resource: A)(f: A => B): B = {
    try f(resource)
    finally resource.close()
  }
}


/** Object to make the reading of a file easier. */
object Reader {
  /** Apply safely a function to a reading file, and close it.
    *
    * @param fileName The path of the file to read.
    * @param f The function to apply to the resource.
    */
  def interpret[B](fileName: String)(f: io.BufferedSource => B): B = {
    Resource.applyFunction(io.Source.fromFile(fileName))(f(_))
  }
}

/** Object to make the writing of a file easier. */
object Writer {
  /** Apply safely a function to a writing file, and close it.
    *
    * @param fileName The path of the file to write.
    * @param f The function to apply to the resource.
    */
  def write[B](fileName: String)(f: java.io.BufferedWriter => B): B = {
    val outputFile = new java.io.File(fileName)
    val bw = new java.io.BufferedWriter(new java.io.FileWriter(outputFile))
    Resource.applyFunction(bw)(f(_))
  }
}
