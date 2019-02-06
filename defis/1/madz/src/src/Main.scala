import donnees._
import java.io.File
import java.io.PrintWriter
import scala.io._

object Main {
  def main(args: Array[String]): Unit= {
    if (args.length <4) {
        println("4 agrs minimum")
    }
    val f= new FeuilleSimple(args(0))
    f.loadCalc()
    val I = new DataInterpreteur(f)
    I.evalCellules()
    I.writeView(args(2))
   
   
  }   
}