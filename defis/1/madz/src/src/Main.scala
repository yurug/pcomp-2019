import donnees._
import java.io.File
import java.io.PrintWriter

object Main {
  def main(args: Array[String]): Unit = {
    val f= new FeuilleSimple("src/data.csv")
    f.loadCalc()
    DataParser.formuleToString(f.cellules)
    DataParser.writeView0(f.cellules)
  }   
}