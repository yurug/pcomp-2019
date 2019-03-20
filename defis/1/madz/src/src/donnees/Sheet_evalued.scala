package donnees

trait Sheet_evalued {
  def start_evaluation
  def getValue(c:Case):Option[Case]
}