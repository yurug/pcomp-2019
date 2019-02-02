
import user_file_parser._
import change._
import utils._
import csv_preprocessor._
import printer._
import dependencies._
import evaluator._
import csv_parser._

object Main {

  def applyUserCommands(
      bw: java.io.BufferedWriter,
      applied: List[Change],
      toApply: List[Change]): Unit = toApply match {
    case Nil => ()
    case c::t =>
      val newApplied: List[Change] = Modifier.applyNewChange(c, applied)
      CommandEffectsPrinter.printEffect(bw, c, newApplied)
      newApplied.foreach {c => println(c.p)}
      applyUserCommands(bw, newApplied, t)
  }

  def main(args: Array[String]): Unit = {
    if(args.size != 4) {
      println("Error, usage : ./ws data.csv user.txt view0.csv changes.txt")
      return
    }

    val ucs: List[Change] = Reader.using(args(1)) { UserFileParser.parse(_) }
    val (uacs, ubcs): (List[AChange], List[BChange]) = Change.split(ucs)
    val fbcs: List[BChange] = Reader.using(args(0)) { CSVParser.parse(_) }
    Reader.using(args(0)) {
      CSVPreProcessor.countInitialValues(_, fbcs ::: ubcs, uacs)
    }

    Dependencies.compute(fbcs)
    Evaluator.evaluateChanges(fbcs)

    Reader.using(args(0)) { input =>
      Writer.using(args(2)) { output =>
        CSVPrinter.printCSVWithChanges(input, output, fbcs)
      }
    }

    Writer.using(args(3)) { applyUserCommands(_, fbcs, ucs) }
  }
}
