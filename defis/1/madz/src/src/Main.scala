import donnees._
import java.io.File
import java.io.PrintWriter

object Main {
  def main(args: Array[String]): Unit = {
    val f= new FeuilleSimple("data.csv")
    f.loadCalc()
    val writer = new PrintWriter(new File("view0.csv"))
    DataParser.formuleToString(f.cellules)
    for(l <- f.cellules){
         for(c <- l){
              writer.write(c.getVal+";")
         }
          writer.write("\n")
      }
   
    writer.close()
    
    
    
    
  }
}