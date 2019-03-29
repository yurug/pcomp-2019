package spreadsheet
case class Case(i:Int, j:Int)
trait Sheet_evalued {
  def getValue(c:Case):Option[Value]
  def start_evaluation
}