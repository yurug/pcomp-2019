import donnees._
import java.io.File
import java.io.PrintWriter
import scala.io._

object Main {
  def main(args: Array[String]): Unit= {
    if (args.length <4) {
        println("4 agrs minimum")
    }
    val f= new FeuilleSimple("src/big.csv","view0.csv")
    f.copyF()
    val dep = new GestionnaireDependance(f)
    dep.addDependanceToList()
   
    dep.MalFormees()
    println(f.listFormule)
    /*
    println(f.writeRes())
    */
  }   
}