/*

cette manière de faire est beaucoup mieux, je trouve
def evalData (data: CaseData): Option[Value]
evaluation donne 1 type Value
def print val = val match{
	case VUnknow => P
	case VInt v => ..
}
*/
package donnees
package object A{
type Value = CaseData  
}

/*
abstract class Value
case class VInt(v : Int) extends Value 
case class VUncalculabe() extends Value
*/