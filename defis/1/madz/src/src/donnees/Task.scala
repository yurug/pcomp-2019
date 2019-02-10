package donnees

trait Task {
  def exec():Unit
  def result_exec():String
}