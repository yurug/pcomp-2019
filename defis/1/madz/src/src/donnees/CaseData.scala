package donnees
abstract class CaseData

case class Number(value: Int) extends CaseData

case class Formule(case_leftTop:Case, 
	case_bottomRight:Case,
	value: Int) extends CaseData
	
case class P() extends CaseData	

case class Case(i:Int, j:Int)