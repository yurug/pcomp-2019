package request
import scala.collection.JavaConverters._

/*
 * A simple scheduler, 
 * all task is independant between its, if a task fail, continue with next task
 * execution task is make in a ordre sequential
 */
 class Basic_Scheduler[T <: Task] extends java.util.ArrayList[T] with Sequential_process[T]{
  private var task_done:List[T] = Nil
  
  /*
   * precondition: exist 1 list TODOtask 
   * postcondition: all successfull executed task is move from list TODO into a list DONE
   */  
   def start_exec() : Unit = {
    def exec_task (task:T) = {
      try{
        task.exec ; 
        task_done = task::task_done
      }catch {
        case e => println("error execute task")
        }
      }
      this.asScala.foreach (exec_task)
      }


  /*
   * return all executed tasks 
   */
   def get_task_done = task_done
 }