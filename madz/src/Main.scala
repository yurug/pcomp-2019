import spreadsheet._
import java.io.File
import java.io.PrintWriter
import scala.io._
import java.io._
import scala.collection.JavaConverters._
import request.Basic_Scheduler
import request.Scheduler
import request.Request_parser
import util.FileCSV_DAO
import request.Estimate_change

object Main {
  
  def main(args: Array[String]): Unit= {
    val data_file = args(0)
    val request_file = args(1)
    val viewOut_file = args(2)
    val changeTODO_file = args(3)
    generate_view0(data_file,viewOut_file)
    generate_change(request_file,changeTODO_file)
  
  }
  def load_scheduler(file : String) ={
    import scala.collection.mutable.MutableList
    import scala.collection.JavaConverters._

    val tmp = new FileCSV_DAO[Estimate_change](file," ") 
    with Request_parser
    tmp.init
    val scheduler = new Basic_Scheduler[Estimate_change]
    tmp.foreach {e => scheduler.add(e)}
    scheduler
  }
  def write_change(scheduler: Scheduler[Estimate_change],changeTODO_file : String)={
        val output = new BufferedWriter(
        new FileWriter(
            new File(changeTODO_file)))
    val result  = scheduler.get_task_done()
    val tmp = result.map(elt => elt.get_result.map(Printer.toString))
    val content = tmp.foldLeft("")((acc,txt) => acc + txt + "\n")    
    output.write(content)
    output.close()
  }

  def generate_view0(data:String, view:String) = {
    val f= new Sheet_evalued_Impl(data, view)
    f.start_evaluation
    f.export()    
  }
  
  def generate_change(request: String,change: String) = {
     val scheduler = load_scheduler(request)
    scheduler.start_exec()
    write_change(scheduler,change)
  }
    
 }
