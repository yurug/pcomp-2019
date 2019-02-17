import donnees._
import java.io.File
import java.io.PrintWriter
import scala.io._
import java.io._
import scala.collection.JavaConverters._
object Main {
  
  def main(args: Array[String]): Unit= {
    val data_file = args(0)
    val request_file = args(1)
    val viewOut_file = args(2)
    val changeTODO_file = args(3)
    
    val sheet = new Sheet_evalued(data_file,viewOut_file)  
    val scheduler = CSV_IO_Scheduler.load_scheduler(request_file,sheet)
    scheduler.start_exec()
    CSV_IO_Scheduler.write_change(scheduler,changeTODO_file)
  }
  

  /*{
    if (args.length <4) {
        println("4 agrs minimum")
    }
    val f= new FeuilleSimple(args(0))
    f.loadCalc()
    val I = new DataInterpreteur(f)
    I.evalCellules()
    I.writeView(args(2))
    */
/*    def test_load_scheduler() = {
      val scheduler = load_scheduler("test/data.txt")
      
    }
*/

    
  }