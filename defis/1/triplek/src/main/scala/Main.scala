
package main

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
      csvName: String,
      commands: Iterator[String],
      formulae: List[BChange],
      oldAChanges: List[AChange]): Unit = {
    if(commands.isEmpty)
      return
    val str: String = commands.next
    val c: Change = UserFileParser.parseCommand(str)
    Reader.interpret(csvName) { csv =>
      c.oldValue = CSVParser.computeOldValue(c, csv, oldAChanges, formulae)
    }
    c match {
      case c: BChange =>
        Reader.interpret(csvName) { csv =>
          CSVPreProcessor.computeInitialValue(c, csv, oldAChanges)
        }
      case _ => ()
    }

    val newApplied: List[Change] = Modifier.applyNewChange(c, formulae)

    CommandEffectsPrinter.printEffect(bw, c, newApplied)
    val (_, newFormulae) = Change.split(newApplied)
    val newAC = oldAChanges.filter { ac => ac.p.equals(c.p) }
    c match {
      case c: BChange =>
        applyUserCommands(bw, csvName, commands, newFormulae, newAC)
      case c: AChange =>
        applyUserCommands(bw, csvName, commands, newFormulae, c::newAC)
    }

  }

  def main(args: Array[String]): Unit = {
    if(args.size != 4) {
      println("Error, usage : ./ws data.csv user.txt view0.csv changes.txt")
      return
    }

    val fbcs: List[BChange] = Reader.interpret(args(0)) { CSVParser.parse(_) }
    Reader.interpret(args(0)) {
      CSVPreProcessor.countInitialValues(_, fbcs)
    }
    println("Terminé")
    /*val actorSystem = ActorSystem("PreprocessSystem")
    val actorList: List[ActorRef] =
      fbcs.map { c =>
        actorSystem.actorOf(Props(new PreprocessActor(c, args(0))))
      }
    actorList.foreach { a => a ! Start}
    actorList.foreach { a => grafec}
    actorSystem.terminate()*/

    Dependencies.compute(fbcs)
    Evaluator.evaluateChanges(fbcs)

    Reader.interpret(args(0)) { input =>
      Writer.write(args(2)) { output =>
        CSVPrinter.printCSVWithChanges(input, output, fbcs)
      }
    }

    Reader.interpret(args(1)) { commandsFile =>
      Writer.write(args(3)) { bw =>
        applyUserCommands(bw, args(2), commandsFile.getLines, fbcs, List())
      }
    }
  }
}
