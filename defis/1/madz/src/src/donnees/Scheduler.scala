package donnees

trait Scheduler [T <: Task] extends Seq[T]{
  def start_exec():Unit
  def get_task_done(): List[T]
}