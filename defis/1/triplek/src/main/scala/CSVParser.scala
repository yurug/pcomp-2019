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
  private def searchFormulaeInLine(cells: Array[String], x: Int, y: Int, l: List[BChange]): List[BChange] = {
    if(y >= cells.size) {
      return l
    }
    CellParser.parse(x, y, cells(y)) match {
      case bc: BChange => searchFormulaeInLine(cells, x, y + 1, bc::l) 
      case _: AChange => searchFormulaeInLine(cells, x, y + 1, l)
    }
  }

  private def process(lines: Iterator[String], x: Int, returned: List[BChange]): List[BChange] = {
    if(lines.isEmpty) {
      return returned
    }
    val line: String = lines.next
    process(lines, x + 1, searchFormulaeInLine(line.split(";"), x, 0, returned))
  }

  /** Parse a CSV file.
    *
    * @param file The file to parse.
    * @return A list of BChange corresponding to the formulae in file.
    */
  def parse(file: scala.io.BufferedSource): List[BChange] = {
    var lines = file.getLines
    process(lines, 0, List())
  }

}
