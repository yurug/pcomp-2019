/*

cette manière de faire est beaucoup mieux, je trouve
def evalData (data: CaseData): Option[Value]
evaluation donne 1 type Value
def print val = val match{
	case VUnknow => P
	case VInt v => ..
}
*/
/*trait Value
case class VInt(v : Int) extends Int with Value 
case class VUnknow extends Value
*/