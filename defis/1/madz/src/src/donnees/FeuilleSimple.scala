package donnees
import scala.io._
import java.io.File

import java.io.PrintWriter

class FeuilleSimple(data0:String,view0:String) extends FeuilleCalque {
  
  
  var listFormule = scala.collection.mutable.Map[Int,(CaseData,List[Int])]()
  var listCoord:Map[Int,(Case)] = Map()
  var listP =List[Int]()
  
  def get_FormuleId(c: Case) = {
    val res = listCoord.find( 
        (K ) => { val _,d = K
        if (d == c) {true} else {false}         
      })
     res match{
          case None => None
          case Some((id, _)) => Some(id) 
        }
  }
  
  def idToCase (id:Int)  = listCoord.get(id) match{
          case None => Nil
          case Some(c) => List(c)
        }
      
        
    
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
  def setCaseData(id:Int,data:CaseData):Unit={
    val Some((data0,l0)) = listFormule.get(id)
    listFormule(id) = (data,l0)
  }
  
  def addDep(id:Int,l:List[Int]):Unit={
    val Some((data,l0)) = listFormule.get(id)
    listFormule(id) = (data,l)
  }
  
  def fileRegion(id:Int):Unit ={
     var Formule(c1,c2,v)=getCaseData(id)
     val writer = new PrintWriter(new File(id+""))
     var i=0;var j=0; var ll=List[String]()
     for(l <- io.Source.fromFile(view0).getLines){
      if(c1.i<=i && i<=c2.i){
        for(c <- l.split(";")){
          if(c1.j<=j && j<=c2.j){
            c::ll
          }else j+=1
        }
        ll=ll.reverse
        writer.write(ll.mkString(" "))
        writer.write("\n")
      }else i+=1
     }
    writer.close()
   }
  
  def getDependance(c:Case):List[Case] = {
    get_FormuleId(c) match {
      case None => Nil //case c is a int
      case Some(id) => { 
        val Some((data,dependances)) = listFormule.get(id)        
        val listCase = dependances.map(id => listCoord.get(id))
        val listClean = listCase.filter(elt => elt match {case None => false case Some(_) => true })
        listClean.map(a => a match {case Some(a) => a})
      }
    }
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
