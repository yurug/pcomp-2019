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
  private def searchFormulaeInLine(str: String, x: Int): List[BChange] = {
    str.split(";").zipWithIndex.map { case (cell, y) =>
      CellParser.parse(x, y, cell)
    }.collect { case bc: BChange => bc }.toList
  }

  /** Parse a CSV file.
    *
    * @param file The file to parse.
    * @return A list of BChange corresponding to the formulae in file.
    */
  def parse(file: scala.io.BufferedSource): List[BChange] = {
    file.getLines.zipWithIndex.map { case (line, x) =>
      searchFormulaeInLine(line, x)
    }.foldLeft(List[BChange]())(_ ::: _)
  }

}
