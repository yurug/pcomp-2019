package csv_parser

import change._
import cell_parser._

/** Parser for CSV file. */
object CSVParser {
  /** Search all the formulae in a line.
    *
    * @param str The line to parse.
    * @param x The x position of the change.
    * @return A list of BChange corresponding to the formulae in `str`.
    */
  private def searchFormulaeInLine(
      cellsWithY: Iterator[(String, Int)],
      x: Int,
      l: List[BChange]): List[BChange] = {
    if(cellsWithY.isEmpty) {
      return l
    }
    val (cell, y) = cellsWithY.next
    CellParser.parse(x, y, cell) match {
      case bc: BChange => bc :: searchFormulaeInLine(cellsWithY, x, l)
      case _           => searchFormulaeInLine(cellsWithY, x, l)
    }
  }

  private def process(
      linesWithX: Iterator[(String, Int)],
      returned: List[BChange]): List[BChange] = {
    if(linesWithX.isEmpty) {
      return returned
    }
    val (line, x): (String, Int) = linesWithX.next
    val cellsWithY: Iterator[(String, Int)] =
      line.split(";").toIterator.zipWithIndex
    process(linesWithX, searchFormulaeInLine(cellsWithY, x, returned))
  }

  /** Parse a CSV file.
    *
    * @param file The file to parse.
    * @return A list of BChange corresponding to the formulae in file.
    */
  def parse(file: scala.io.BufferedSource): List[BChange] = {
    var linesWithX = file.getLines.zipWithIndex
    process(linesWithX, List())
  }

  def computeOldValue(
      c: Change,
      file: scala.io.BufferedSource,
      oldA: List[AChange],
      oldB: List[BChange]): Int = oldB.find(_.p.equals(c.p)) match {
    case Some(elem) =>
      println("Fuck!")
      return elem.v
    case None =>
      oldA.find(_.p.equals(c.p)) match {
        case Some(elem) =>
          println("The")
          return elem.v
        case None =>
          println("What")
          file.getLines.drop(c.p.x).next.split(";")(c.p.y).toInt
      }
  }
}
