package donnees
import scala.io._



class FeuilleSimple(data:String) extends FeuilleCalque{

  val feuille = Source.fromFile(data)
  val fileToArray=feuille.getLines().toArray.map(s => s.split(";"))
  
  final protected var cellules = Array.ofDim[Cellule](fileToArray.length,fileToArray(0).length)
  
  def loadCalc(): Unit = {
    var i=0;var j=0
    for(l <- fileToArray){
      for(c <- l){
        cellules(i)(j) = new Cellule( Some (DataParser.parseData(c)))
        j+=1
      }
      i+=1;j=0
    }
  }
  
  def getFeuille:
    	Array[Array[Cellule]]=cellules
    
  def writeCell(c:Case, v:CaseData): Unit = {
    cellules(c.i)(c.j) = new Cellule(Some (v))
  }

  final def getData(c: Case) = cellules(c.i)(c.j).getVal
  
  final def getEvalRegion(c1:Case, c2:Case,v:Int):CaseData={
    var count=0
    for(i <- c1.i to c2.i)
      for(j <- c1.j to c2.j){
       getData(Case(i,j)) match {
         case Some (Number (n)) => if (n == v) count+=1
			   case Some (Formule (_,_,_)) => return P()
			   case _ => return P()
       }
      }
   return Number(count)
  }
  
  final def getRegion(case_leftTop:Case, case_bottomRight:Case):Array[Array[Cellule]]={
      val row = cellules.slice(case_leftTop.i ,case_bottomRight.i)
      row.map (column => {
              val interval_selected = column.slice(case_leftTop.j ,case_bottomRight.j)
              interval_selected.map (cell => cell.getVal)
            })
            row
  }
  
  final def getSize: (Int, Int) = (fileToArray.length,fileToArray(0).length)  
  
  final def iterator = {
    val ite = new Array(0).iterator
      for (i <- 0 until (cellules(0).length - 1))
        ite ++ cellules(i).iterator
       ite
  }
  
 

}
