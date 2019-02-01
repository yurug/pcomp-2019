
import user_file_parser._
import change._
import utils._
import csv_preprocessor._
import printer._
import dependencies._
import evaluator._
import csv_parser._
import java.io._

object Main {

  def applyUserCommands(
      bw: BufferedWriter,
      applied: List[Change],
      toApply: List[Change]): Unit = toApply match {
    case Nil => ()
    case c::t =>
      val newApplied: List[Change] = Modifier.applyNewChange(c, applied)
      CommandEffectsPrinter.printEffect(bw, c, newApplied)
      applyUserCommands(bw, newApplied, t)
  }

  def main(args: Array[String]): Unit = {
    if(args.size != 4) {
      println("Error, usage : ./ws data.csv user.txt view0.csv changes.txt")
      return
    }

    val ucs: List[Change] = MyReader.using(args(1)) { UserFileParser.parse(_) }
    val (uacs, ubcs): (List[AChange], List[BChange]) = Change.split(ucs)
    val fbcs: List[BChange] = MyReader.using(args(0)) { CSVParser.parse(_) }
    MyReader.using(args(0)) {
      CSVPreProcessor.countInitialValues(_, fbcs ::: ubcs, uacs)
    }

    Dependencies.compute(fbcs)
    Evaluator.evaluateChanges(fbcs)

    MyReader.using(args(0)) { input =>
      MyWriter.using(args(2)) { output =>
        CSVPrinter.printCSVWithChanges(input, output, fbcs)
      }
    }

    MyWriter.using(args(3)) { applyUserCommands(_, fbcs, ucs) }
  }
}
