package spreadsheet
case class Case(i:Int, j:Int)
trait Sheet_evalued {
  def getValue(c:Case):Option[Value]
  def start_evaluation
  def eval_expr(expr: CaseData):Value
  def getDependace(c:Case):List[Case]
  def formule_of(c:Case):Option[Formule]
}