import donnees._
import java.io.File
import java.io.PrintWriter
import scala.io._
import java.io._
import scala.collection.JavaConverters._
object Main {
  
  def main(args: Array[String]): Unit= {
    /*val data_file = args(0)
    val request_file = args(1)
    val viewOut_file = args(2)
    val changeTODO_file = args(3)
    */
   /* val scheduler = load_scheduler(request_file)
    scheduler.start_exec()
    write_change(scheduler,changeTODO_file)
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
    val tmp = result.map(elt => elt.get_result.map(PrinterCSV.toString))
    val content = tmp.foldLeft("")((acc,txt) => acc + txt + "\n")    
    output.write(content)
    output.close()
  }*/
  
    
    val f= new FeuilleSimple("src/data.csv","src/view0.csv")
    f.copyF()
    val dep = new GestionnaireDependance(f)
    dep.addDependanceToList()
    dep.BienFormees()
    dep.MalFormees()
    println(f.listFormule)
    f.writeRes()
    
   

  }
    
 }
