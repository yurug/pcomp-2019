package donnees
import scala.io._

class FeuilleSimple(feuille:BufferedSource) extends FeuilleCalque {
  
  final protected var cellules = Array.ofDim[Cellule](2,4)
  
  def getCellules = cellules
  
  def loadCalc(): Unit = {
    var i=0;var j=0
    println("ok")
   for(l <- feuille.getLines()){
      println(l)
      for(c <- l.split(";")){
        cellules(i)(j) = new Cellule( Some (DataParser.parseData(c)))
        j+=1
      }
      i+=1;j=0
    }
  }
  
  def getCell(c:Case): Cellule = {
    cellules(c.i)(c.j)
  }

  def writeCell(c:Case, v:CaseData): Unit = {
    cellules(c.i)(c.j) = new Cellule(Some (v))
  }

  final def getData(c: Case) = cellules(c.i)(c.j).getVal
  
  final def getRegion(case_leftTop:Case, case_bottomRight:Case) ={
      val row = cellules.slice(case_leftTop.i ,case_bottomRight.i)
      row.map (column => {
              val interval_selected = column.slice(case_leftTop.j ,case_bottomRight.j)
              interval_selected.map (cell => cell.getVal)
            })
      }
  
  final def getSize: (Int, Int) ={
      val i = cellules.length
      val j = cellules(0).length
      (i,j)
  }
  
  final def iterator = {
     /* val ite = new Array(0).iterator
      for (i <- 0 until (cellules(0).length - 1))
        ite ++ cellules(i).iterator
    */
    null
  }

}
