package donnees
import scala.io.Source

class FeuilleSimple(file:String) extends FeuilleCalque {
  private def parseData = DataParser.parseData 

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

  def writeCell(r:Int, c:Int, v:String): Unit = {
    cellules(r)(c) = new Cellule(v)
  }

  final def getData(c: Case) : CaseData = parseData (cellules(c.i)(c.j).getVal)
  final def getRegion(case_leftTop:Case, case_bottomRight:Case): Array[Array[CaseData]] ={
      val row = cellules.slice(case_leftTop.i ,case_bottomRight.i)
      row.map (column => {
              val interval_selected = column.slice(case_leftTop.j ,case_bottomRight.j)
              interval_selected.map (cell => parseData (cell.getVal))
            })
    }
  final def getSize: (Int, Int) ={
      val i = cellules.length
      val j = cellules(0).length
      (i,j)
  }
  final def iterator: Iterator[donnees.CaseData] = {
      val ite = new Array(0).iterator
      for (i <- 0 until (cellules(0).length - 1))
        ite ++ cellules(i).iterator
    }

}
