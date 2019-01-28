package donnees
import scala.io.Source

class FeuilleSimple(file:String) extends FeuilleCalque {

  /*chargement du fichier et stockage dans la variable "cellules" 
  *Array [][]
  */
  val feuille = Source.fromFile(file) 
  val lines = feuille.getLines()
  val cellules = Array.ofDim[Cellule](lines.slice(0,1).toList.headOption.get.toInt,lines.size)
  
  def loadCalc(): Unit = {
    var i=0
    var j=0
    for(l <- lines){
      for(c <- l.split(";")){
        cellules(i)(j) = new Cellule( DataParser.parseData(c))
        j+=1
      }
      i+=1
    }
  }
  
  def getCell(c:Case): Cellule = {
    cellules(c.i)(c.j)
  }
  
  def writeCell(c:Case, v:CaseData): Unit = {
    cellules(c.i)(c.j) = new Cellule(v)
  }
  
  def getData(c: Case) : CaseData = cellules(c.i)(c.j).getVal
  
  
  
  
}
