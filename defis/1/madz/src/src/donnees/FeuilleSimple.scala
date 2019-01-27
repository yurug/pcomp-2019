package donnees
import scala.io.Source

class FeuilleSimple(file:String) extends FeuilleCalque {

  /*chargement du fichier et stockage dans la variable "cellules" 
  *Array [][]
  */
  private def parseData = DataParser.parseData
  val feuille = Source.fromFile(file) 
  val lines = feuille.getLines()
  val cellules = Array.ofDim[Cellule](lines.slice(0,1).toList.headOption.get.toInt,lines.size)
  
  def loadCalc(): Unit = {
    var i=0
    var j=0
    for(l <- lines){
      for(c <- l.split(";")){
        cellules(i)(j) = new Cellule(c)
        j+=1
      }
      i+=1
    }
  }
  
  def getCell(r:Int , c:Int): Cellule = {
    cellules(r)(c)
  }
  def writeCell(r:Int, c:Int, v:String): Unit = {
    cellules(r)(c) = new Cellule(v)
  }

  def getData(c: Case) : CaseData = parseData (cellules(c.i)(c.j))
  
}
