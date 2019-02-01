package user_file_parser

import change._
import cell_parser._

/** Parser for CSV modification command file */
object UserFileParser {

  /** Parse a command line which modifies a CSV
    *
    * @param str The command to parse.
    * @return The Change created from the command.
    */
  private def parseLine(str: String): Change = {
    val Array(x, y, cell) = str.split(" ", 3)
    return CellParser.parse(x.toInt, y.toInt, cell)
  }

  /** Parse a file of command line modifying a CSV
    *
    * @param file The file to parse.
    * @return A list of the Change created from the commands of the file.
    */
  def parse(file: io.BufferedSource): List[Change] = {
    file.getLines.map(parseLine).toList
  }

}
