package request
import scala.collection.JavaConverters._

/*
 * launch 
 */
class Basic_Scheduler[T <: Task] extends java.util.ArrayList[T] with Sequential_process[T]{
  private var task_done:List[T] = Nil
  
  /*
   * precondition: exist 1 list task TODO
   * postcondition: all executed task is move from list TODO into a list DONE
   */  
  def start_exec() : Unit = this.asScala.foreach (task => {task.exec ; 
  task_done = task::task_done})
  
  /*
   * return all executed tasks 
   */
  def get_task_done = task_done
}