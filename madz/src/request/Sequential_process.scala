package request


/*

import request.Task * scheduler such as task is executed sequentialy
 */
trait Sequential_process[T <: Task] extends Scheduler[T]  
{
  
}