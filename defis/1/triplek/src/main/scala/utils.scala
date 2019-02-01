package utils

import scala.math.Ordering.Implicits._
import scala.language.{reflectiveCalls}
import change._
import java.io._

class Position(val x: Int, val y: Int) {
  override def toString = s"(${x}, ${y})"

  def >(other: Position): Boolean = (x, y) > (other.x, other.y)
}

class Block(val topLeft: Position, val bottomRight: Position) {

  def this(r1:Int, c1:Int, r2:Int, c2:Int) = {
    this(new Position(r1, c1), new Position(r2, c2))
  }
  def contains(position: Position): Boolean = {
    return position.x >= topLeft.x && position.x <= bottomRight.x &&
           position.y >= topLeft.y && position.y <= bottomRight.y
  }

  def isAfter(p: Position): Boolean = {
    topLeft > p
  }
}


object Resource {
  def using[A <: { def close(): Unit }, B](resource: A)(f: A => B): B = {
    try f(resource)
    finally resource.close()
  }
}

object MyReader {
  def using[B](fileName: String)(f: io.BufferedSource => B): B = {
    Resource.using(io.Source.fromFile(fileName))(f(_))
  }
}

object MyWriter {
  def using[B](fileName: String)(f: BufferedWriter => B): B = {
    val outputFile = new File(fileName)
    val bw = new BufferedWriter(new FileWriter(outputFile))
    Resource.using(bw)(f(_))
  }
}
