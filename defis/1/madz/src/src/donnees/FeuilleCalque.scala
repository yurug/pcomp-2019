package donnees

// Représentation de la feuille de calque et accès lecture écriture case par case
abstract class CaseData
case class Number(value: Int) extends CaseData
case class Formule(case_leftTop:Case, 
	case_bottomRight:Case,
	value: Int) extends CaseData

case class Case(i:Int, j:Int)

trait FeuilleCalque {
  def loadCalc(): Unit
  def getCell(r:Int , c:Int): Cellule
  def writeCell(r:Int, c:Int, v:String): Unit
  def getRegion(case_leftTop:Case, case_bottomRight:Case): Array[Array[CaseData]]
  def iterator : scala.collection.Iterator
  def getSize : (Int,  Int)
  def getData(c: Case) : CaseData
}