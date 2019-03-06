package donnees
import scala.collection.JavaConverters._
import _root_.task_scheduler._;

class Basic_Scheduler[T <: Task] extends java.util.ArrayList[T] with Sequential_process[T]{
  private var task_done:List[T] = Nil
  
  def start_exec() : Unit = {
    def exec_task(task:T) = {task.exec ; 
  task_done = task::task_done}      
    this.asScala.foreach ( exec_task )
  }
      
  
  
  def get_task_done = task_done
}