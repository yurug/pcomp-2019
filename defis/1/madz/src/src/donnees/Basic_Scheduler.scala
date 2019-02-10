package donnees
import scala.collection.mutable.MutableList


class Basic_Scheduler[T <: Task] extends MutableList[T] with Sequential_process[T]{
  private var task_done:List[T] = Nil
  
  def start_exec() : Unit = this.foreach (task => {task.exec ; 
  task_done = task::task_done})
  
  def get_task_done = task_done
}