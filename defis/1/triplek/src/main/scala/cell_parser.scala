package cell_parser

import utils._
import change._

/** Exception for impossible parsing (not valid value, bad formatting, etc.) */
final case class InvalidCellContentException(
    private val message: String = "")
  extends Exception(message)


/** Parser for CSV cell string */
object CellParser {
  val aCell = """(\d+)""".r
  val bCell = """=#\((\d+), (\d+), (\d+), (\d+), (\d+)\)""".r

  /** Creata a Achange from a position and a value
    *
    * @param x The x position of the cell.
    * @param y The y position of the cell.
    * @param v The value of the cell.
    */
  private def createA(x: Int, y: Int, v: Int): AChange = {
    if(v.toInt < 0 || v.toInt > 255) {
      throw new InvalidCellContentException(
        s"Invalid value ${v} at position (${x}, ${y}.")
    }
    new AChange(x, y, v.toInt)
  }

  /** Create a Bchange from a position, a block and a value to count.
    *
    * @param x The x position of the cell.
    * @param y The y position of the cell.
    * @param r1 The x position of the top left corner.
    * @param c1 The y position of the top left corner.
    * @param r2 The x position of the bottom right corner.
    * @param c2 The y position of the bottom right corner.
    * @param vc The value that the cell count is the block.
    */
  private def createB(
      x: Int,
      y: Int,
      r1: Int,
      c1: Int,
      r2: Int,
      c2: Int,
      vc: Int): BChange = {
    new BChange(x, y, r1, c1, r2, c2, 0, vc)
  }

  /** Parse a string and create a Change with the given position.
    *
    * @param x The x position of the cell.
    * @param y The y position of the cell.
    * @param cell The string to parse.
    *
    * @return The change build with the string and the position.
    */
  @throws(classOf[InvalidCellContentException])
  def parse(x: Int, y:Int, cell: String): Change = {
    cell match {
      case aCell(v) => createA(x, y, v.toInt)
      case bCell(r1, c1, r2, c2, vc) =>
        createB(x, y, r1.toInt, c1.toInt, r2.toInt, c2.toInt, vc.toInt)
      case _ =>
        throw new InvalidCellContentException(
          s"Cannot parse ${cell} at position (${x}, ${y}.")
    }
  }

}
