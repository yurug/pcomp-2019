package csv_parser

import change._
import cell_parser._

/** Parser for CSV file. */
object CSVParser {
  /** Search recursively all the formulae in a line of cells.
    *
    * @param cellsWithY The cells to process with value and y position.
    * @param x The x position of the change
    * @param l The formulae which has been already found.
    * @return A list of BChange corresponding to the formulae in `cellsWithY`.
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

  /** Search recursively all the formulae in lines of cells.
    *
    * @param linesWithX The lines to process with value and x position.
    * @param returned The formulae which has been already found.
    * @return A list of BChange corresponding to the formulae in `linesWithX`.
    */
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


  /** Compute the old value of a `Change` in a CSV file (that is to say the values
    *  which was present at its position).
    *
    * @param c The `Change` whose the old value should be computed.
    * @param file The Buffer corresponding to the CSV file.
    * @param oldB All the formulae `BChange`, because, maybe there was a
                  formulae at this position (in fact it is useless since
                  the file contains the value).
    * @return The old value of `c`.
    */
  def computeOldValue(
      c: Change,
      file: scala.io.BufferedSource,
      oldB: List[BChange]): Int = oldB.find(_.p.equals(c.p)) match {
    case Some(elem) =>
      return elem.v
    case None =>
      file.getLines.drop(c.p.x).next.split(";")(c.p.y).toInt
  }
}
