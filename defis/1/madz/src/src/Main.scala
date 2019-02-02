import donnees._
import java.io.File
import java.io.PrintWriter
import scala.io._

object Main {
  def main(args: Array[String]): Unit= {
    if (args.length <4) {
        println("4 agrs minimum")
    }
    val feuille = Source.fromFile(args(0)) 
    val f= new SimpleFeuilleWithDependance(feuille)
    f.loadCalc()
    println(f.getCellules(0)(0))
    val interpreter = new Interpreteur_implement(f)
    interpreter.evalSheet
    val user = Source.fromFile(args(1))
    val gr = new GestionRequete(user)
//    DataParser.writeView0(f.cellules) 
  }   
}