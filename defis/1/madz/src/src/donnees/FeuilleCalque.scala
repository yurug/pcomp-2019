package donnees

// Représentation de la feuille de calque et accès lecture écriture case par case
trait FeuilleCalque {
  def loadCalc(): Unit
  def getCell(r:Int , c:Int): Cellule
  def writeCell(r:Int, c:Int, v:String): Unit
  def getRegion(case_leftTop:Case, case_bottomRight:Case): Array[Array[CaseData]]
  def iterator : scala.collection.Iterator[CaseData]
  def getSize : (Int , Int)
  def getData(c: Case) : CaseData
}