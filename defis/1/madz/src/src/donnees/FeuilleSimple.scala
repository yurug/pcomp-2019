package donnees
import scala.io.Source

class FeuilleSimple(file:String) extends FeuilleCalque {
  
  var cellules = null
  
  //chargement du fichier et stockage dans la variable "cellules" (quel format pr cette var??)
  def loadCalc(file:String): Unit = {
    val feuille = Source.fromFile(file)
    
    for (line <- feuille.getLines) {
      val splittedLine = line.split(";")
      
    }
  }
  
  def getCell(r:Int , c:Int): Cellule = null
  def writeCell(r:Int, c:Int, v:Int): Unit = null
}
