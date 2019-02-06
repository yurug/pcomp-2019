package donnees

// Représentation de la feuille de calque et accès lecture écriture case par case
trait FeuilleCalque {
  def writeCell(c:Case, v:CaseData): Unit
  def getRegion(case_leftTop:Case, case_bottomRight:Case):Array[Array[Cellule]]
  def iterator : scala.collection.Iterator[Option[CaseData]]
  def getSize : (Int , Int)
  def getData(c: Case) : Option[CaseData]
  
}