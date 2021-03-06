/*

cette manière de faire est beaucoup mieux, je trouve
def evalData (data: CaseData): Option[Value]
evaluation donne 1 type Value
def print val = val match{
	case VUnknow => P
	case VInt v => ..
}
*/
package spreadsheet



abstract class Value
case class VInt(v : Int) extends Value {
  def to_int = v
}
case class VUncalculable() extends Value
