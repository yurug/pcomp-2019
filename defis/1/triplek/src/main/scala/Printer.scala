package printer

import change._
import utils._

/** Module to print the effects of a command. */
object CommandEffectsPrinter {

  /** Format a description of a command change.
    *
    * @param c The command to descibe.
    * @return A string corresponding to the command.
    */
  private def changeDescription(c: Change): String = c match {
    case  c:AChange => s"""${c}":"""
    case c:BChange => {
      s"""=#(${c.b.topLeft.x},
          |${c.b.topLeft.y},
          |${c.b.bottomRight.x},
          |${c.b.bottomRight.y},
          |${c.counted})":""".stripMargin.replaceAll("\n", " ")
    }
  }

  /** Print all the changes caused by a command into a buffer.
    *
    * @param bw The buffer where the changes should be written.
    * @param c The change associeted to the command.
    * @param l A list of all the eventual changes caused by `c`.
    */
  def printEffect(bw: java.io.BufferedWriter, c: Change, l: List[Change]) = {
    bw.write(s"""after "${c.p.x} ${c.p.y} """)
    bw.write(changeDescription(c))
    bw.write("\n")
    l.sortBy { c => (c.p.x, c.p.y) }. foreach { c =>
      if(c.hasChanged) {
        bw.write(s"${c.p.x} ${c.p.y} ${c}\n")
      }
    }
  }
}

/** Module to print CSV. */
object CSVPrinter {

  /** Search for the first change at a certain position.
    *
    * @param p The position.
    * @param l The list of `Change`, It is assumed sorted by position.
    * @return An optional change (a change if there was one at the position  `p`
    *         and else None), and the rest of the changes (all the changes
              at a position after `p`).
    */
  private def getNextChange(
    p: Position,
    l: List[Change]): (Option[Change], List[Change]) = l match {
    case Nil => (None, l)
    case c::t =>
      if(c.p.equals(p))
        return (Some(c), t)
      return (None, l)
  }

  private def printLine(
      bw: java.io.BufferedWriter,
      cellsWithY: Iterator[(String, Int)],
      x: Int,
      l: List[Change]): List[Change] = {
    if(cellsWithY.isEmpty)
      return l
    val (cell, y) = cellsWithY.next
    if(y != 0) bw.write(";")
    val p: Position = new Position(x, y)
    val (c, rest) = getNextChange(p, l)
    l.find { c => c.p.equals(p) } match {
      case Some(c) => bw.write(c.toString)
      case _       => bw.write(cell.toInt.toString)
    }
    return printLine(bw, cellsWithY, x, rest)
  }

  private def auxPrint(
    bw: java.io.BufferedWriter,
    linesWithX: Iterator[(String, Int)],
    changes: List[Change]): Unit = {
      if(linesWithX.isEmpty)
        return
      val (line, x): (String, Int) = linesWithX.next
      val cellsWithY = line.split(";").iterator.zipWithIndex
      val rest: List[Change] = printLine(bw, cellsWithY, x, changes)
      bw.write("\n")
      auxPrint(bw, linesWithX, rest)
    }


    /** Print a new CSV from a first CSV and the changes applied (formulae
      * evaluation, etc.)
      *
      * @param file The buffer corresponding to the input CSV.
      * @param output The buffer where the changes should be written.
      * @param cs A list of all the changes to take into account.
      */
  def printCSVWithChanges(
      file: scala.io.BufferedSource,
      output: java.io.BufferedWriter,
      cs: List[Change]) = {
    val rest: List[Change] = cs.sortBy(c => (c.p.x, c.p.y))
    auxPrint(output, file.getLines.zipWithIndex, rest)
  }
}
