package donnees
import scala.collection.JavaConverters._

class Basic_Scheduler[T <: Task] extends java.util.ArrayList[T] with Sequential_process[T]{
  private var task_done:List[T] = Nil
  
  def start_exec() : Unit = this.asScala.foreach (task => {task.exec ; 
  task_done = task::task_done})
  
  
  def get_task_done = task_done
}