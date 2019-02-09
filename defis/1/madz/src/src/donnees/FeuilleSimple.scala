package donnees
import scala.io._

class FeuilleSimple(data0:String,view0:String) extends FeuilleCalque {
  
  var listFormule:Map[Int,(CaseData,List[Int])] = Map()
  var listCoord:Map[Int,(Case)] = Map()
  var listP =List[Int]()

  def copyF():Unit ={
    val out = new java.io.BufferedWriter( new java.io.FileWriter(view0) );
    var i=0
    io.Source.fromFile(data0).getLines.foreach(
        s => {
          val l=copyligne(s,i)
          out.write(l,0,l.length);
          out.write("\n",0,1)
          i+=1
          });
    out.close()
  }
  
  def copyligne(s:String,numligne:Int):String={
    var l=List[Int]()
    var numcol=0
    for(ss <-s.split(";")){
      val casedata=DataParser.parseData(ss)
      casedata match{
        case Number(n) => l=n::l
        case Formule(c1,c2,v) => 
              l=listCoord.size::l
              listFormule += (listCoord.size -> (Formule(c1,c2,v),Nil))
              listCoord += (listCoord.size -> Case(numligne,numcol))
              println(listCoord.size)
        case _ => Nil
     }
      numcol+=1
    }
    l=l.reverse
    l.mkString(";") 
  }
 
  def getView:String=view0
  def getdata:String=data0
  
  def getCaseData(id:Int):CaseData={
    val Some((data,l)) = listFormule.get(id)
    data
  }
  def writeDep():String={
    var l= List[String]()
    for((id,c) <- listCoord){
      l =DataParser.formuleToString(getCaseData(id))::l
    }
    //normalement il faut cherche la cas X Y dans le view0 mais la juste pour le test
    l=l.reverse
    l.mkString(";") 
  }
  
}
