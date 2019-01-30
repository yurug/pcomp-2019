import donnees._
import java.io.File
import java.io.PrintWriter
import scala.io._

object Main {
  def main(args: Array[String]): Int= {
    if (args.length <4) {
        println("4 agrs minimum")
        return 0
    }
    val feuille = Source.fromFile(args(0)) 
    val f= new FeuilleSimple(feuille)
    f.loadCalc()
    println(f.cellules(0)(0))
    
    DataParser.formuleToString(f.cellules)
    DataParser.writeView0(f.cellules) 
    return 1
  }   
}