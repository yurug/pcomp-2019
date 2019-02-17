package donnees
import donnees._
import java.io.File
import java.io.PrintWriter
import scala.io._
import java.io._
import scala.collection.JavaConverters._

object CSV_IO_Scheduler extends Basic_Scheduler{
  /*
   * load user instruction on 1 sheet from 1 file  
   */
  def load_scheduler(file : String, sheet : Sheet_evalued) ={
    import scala.collection.mutable.MutableList
    import scala.collection.JavaConverters._

    val tmp = new FileCSV_DAO[Estimate_change](file," ") 
    with Estimate_change_CSVparser
    tmp.init
    val scheduler = new Basic_Scheduler[Estimate_change]
    
    tmp.foreach {e =>  {
      e.set_sheet_evalued(sheet)
      scheduler.add(e)}
    }
    scheduler
  }
  def write_change(scheduler: Scheduler[Estimate_change],changeTODO_file : String)={
        val output = new BufferedWriter(
        new FileWriter(
            new File(changeTODO_file)))
    val result  = scheduler.get_task_done()
    val tmp = result.map(elt => elt.get_result.map(PrinterCSV.toString))
    val content = tmp.foldLeft("")((acc,txt) => acc + txt + "\n")    
    output.write(content)
    output.close()
  }  
}