package printer

import change._
import utils._

object CommandEffectsPrinter {

  private def changeDescription(c: Change): String = c match {
    case  c:AChange => s"""${c}""""
    case c:BChange => {
      s"""=#(${c.b.topLeft.x},
          |${c.b.topLeft.y},
          |${c.b.bottomRight.x},
          |${c.b.bottomRight.y},
          |${c.counted})"""".stripMargin.replaceAll("\n", " ")
    }
  }

  def printEffect(bw: java.io.BufferedWriter, c: Change, l: List[Change]) = {
    bw.write(s"""after "${c.p.x} ${c.p.y} """)
    bw.write(changeDescription(c))
    bw.write("\n")
    l.sortBy { c => (c.p.x, c.p.y) }. foreach { c =>
      if(c.hasChanged) {
        bw.write(s"${c.p.x}, ${c.p.y}, ${c}\n")
      }
    }
  }
}


object CSVPrinter {

  private def printLine(
      bw: java.io.BufferedWriter,
      line: String, x: Int,
      l: List[Change]): List[Change] = {
    var rest: List[Change] = l
    var y: Int = 0
    line.split(";").foreach { case cell  =>
      if(y != 0) bw.write(";")

      while(!rest.isEmpty && rest.head.p.x <= x && rest.head.p.y < y)
        rest = rest.tail

      if(!rest.isEmpty && rest.head.p.x == x && rest.head.p.y == y) {
        bw.write(rest.head.toString)
        rest = rest.tail
      }
      else
        bw.write(cell.toInt.toString)
      y += 1
    }
    bw.write("\n")
    rest
  }

  def printCSVWithChanges(
      file: scala.io.BufferedSource,
      output: java.io.BufferedWriter,
      cs: List[Change]) = {
    var rest: List[Change] = cs.sortBy(c => (c.p.x, c.p.y))
    var x: Int = 0
    file.getLines.foreach { case line =>
      rest = printLine(output, line, x, rest)
      x += 1
    }
  }
}
