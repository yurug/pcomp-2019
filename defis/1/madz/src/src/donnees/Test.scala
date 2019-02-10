package donnees

class Test {
  def test_CSVFile = new CSVFile("../data.csv"," ").nextData
  def test_CSVRequest = {
        val tmp = new FileCSV_DAO[Request_change]("/media/zhenlei/d9a893e2-fca5-420b-b051-6af76555b97e/home/zhenlei/XXX/projet/fac/pcomp-2019/defis/1/madz/src/src/test/basic/user.txt"," ") 
    with Request_parser
    tmp.init
    val v1 = tmp.next ()
    val v2 = tmp.next ()
    print(v1)
    print(v2)
  }
  def test_load_scheduler ={
    import scala.collection.mutable.MutableList
import scala.collection.JavaConverters._

    val file = "/media/zhenlei/d9a893e2-fca5-420b-b051-6af76555b97e/home/zhenlei/XXX/projet/fac/pcomp-2019/defis/1/madz/src/src/test/basic/user.txt"
    val tmp = new FileCSV_DAO[Request_change](file," ") 
      with Request_parser
    tmp.init
    val scheduler = new Basic_Scheduler[Request_change]
    tmp.foreach {e => scheduler.add(e)}
    scheduler.asScala.foreach{println}    
  }
}