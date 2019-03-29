package request

trait Scheduler [T <: Task] extends java.util.List[T]{
  def start_exec():Unit
  def get_task_done(): List[T]
}