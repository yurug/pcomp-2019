package test_unit
import org.junit.Assert._;
import donnees._;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import junit.framework.TestCase

class Test_scheduler_execution2 extends TestCase{
  	@Test
  	var scheduler : Basic_Scheduler[Estimate_change] = null
  	var sheet: Sheet_evalued = null
	def testExec() = {
  	  val res_exec = List(
		        Change( Case(0,1), VInt(3)),
		        Change( Case(1,3), VInt(1))
		            )
		scheduler.start_exec()
		assertEquals(1,scheduler.get_task_done().size)
		assertEquals(res_exec,
		    scheduler.get_task_done().head.get_result 
		    )   
		
	}
  	@Before
  	override def setUp() {
  	      val data_file = "test/data.csv"
    val request_file = "test/user.txt"
    val viewOut_file = "test/view0.csv"
    
    sheet = new Sheet_evalued(data_file,viewOut_file)  
    scheduler = CSV_IO_Scheduler.load_scheduler(request_file,sheet)
  	}
}