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
      oldCSV: String,
      commands: Iterator[String],
      formulae: List[BChange],
      newCSV: String): Unit = {
    if(commands.isEmpty)
      return
    val str: String = commands.next
    val c: Change = UserFileParser.parseCommand(str)
    Reader.interpret(oldCSV) { csv =>
      c.oldValue = CSVParser.computeOldValue(c, csv, formulae)
    }

    c match {
      case c: BChange =>
        Reader.interpret(oldCSV) { csv =>
          CSVPreProcessor.computeInitialValue(c, csv, formulae)
        }
      case _ =>
    }

    val newApplied: List[Change] = Modifier.applyNewChange(c, formulae)

    CommandEffectsPrinter.printEffect(bw, c, newApplied)
    Reader.interpret(oldCSV) { input =>
      Writer.write(newCSV) { output =>
        CSVPrinter.printCSVWithChanges(input, output, newApplied)
      }
    }

    val (_, newFormulae) = Change.split(newApplied)
    if(newCSV == "aux.csv")
      applyUserCommands(bw, newCSV, commands, newFormulae, oldCSV)
    else
      applyUserCommands(bw, newCSV, commands, newFormulae, "aux.csv")
  }

  def main(args: Array[String]): Unit = {
    if(args.size != 4) {
      println("Error, usage : ./ws data.csv user.txt view0.csv changes.txt")
      return
    }

    println("Parsage CSV.")
    val fbcs: List[BChange] = Reader.interpret(args(0)) { CSVParser.parse(_) }

    println("Preprocessing.")
    Reader.interpret(args(0)) {
      CSVPreProcessor.countInitialValues(_, fbcs)
    }

    println("Évaluation du fichier.")
    Dependencies.compute(fbcs)
    Evaluator.evaluateChanges(fbcs)

    println("Création CSV")
    Reader.interpret(args(0)) { input =>
      Writer.write(args(2)) { output =>
        CSVPrinter.printCSVWithChanges(input, output, fbcs)
      }
    }

    println("Évaluation des commandes.")
    Reader.interpret(args(1)) { commandsFile =>
      Writer.write(args(3)) { bw =>
        applyUserCommands(bw, args(2), commandsFile.getLines, fbcs, "bux.csv")
      }
    }
  }
}
