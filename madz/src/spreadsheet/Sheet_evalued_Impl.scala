package spreadsheet
import java.io.File
import java.io.PrintWriter

/*
 * 
 */
class Sheet_evalued_Impl(data0:String,view0:String) extends Sheet_evalued {
  
  private val dep = new FormuleEvaluator(this)
  
  /*
   * precondition: exist a file data0 with correct syntax 
   * postcondition: file view0 have data evalued of file data0
   */
  def start_evaluation = {
    try{
     eval_number()    
    dep.start_evaluation
    }catch{
      case e => e.printStackTrace() 
    }

  }
    
  /*
   * precondition: exist a file data0 with correct syntax 
   * postcondition: file view0 contain int data of file data0
   */
  private def eval_number():Unit ={
    var out : java.io. BufferedWriter = null
    try{
      out = new java.io.BufferedWriter( new java.io.FileWriter(view0) );
    var i=0
    io.Source.fromFile(data0).getLines.foreach(
        s => {
          val l=copyligne(s,i)
          out.write(l,0,l.length);
          out.write("\n",0,1)
          i+=1
          });
    }
    finally{
       out.close()
    }
   
  }

  /*
   * precondition: exist a file data0 with correct syntax 
   * postcondition: file view0 's line numligne contain int data of file data0 's line numligne
   */  
  private def copyligne(s:String,numligne:Int):String={
    var l=List[Int]()
    var numcol=0
    for(ss <-s.split(";")){
      val casedata=DataParser.parseData(ss)
      casedata match{
        case Number(n) => l=n::l
        case Formule(c1,c2,v) => dep.add_formule(Formule(c1,c2,v),numligne,numcol)
              l=dep.listCoord_size::l
 
        case _ => Nil
     }
      numcol+=1
    }
    l=l.reverse
    l.mkString(";") 
  }
 
   def getView:String=view0
   def getdata:String=data0
  

  

  private def regionToFile(id:Int):Unit ={
     var writer:PrintWriter = null
     try{
     var Formule(c1,c2,v)=dep.getCaseData(id)
     writer = new PrintWriter(new File(id+""))
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
     }finally{
       writer.close()
     }

    
   }
  


   def getValue(c:Case):Option[Value]={
    var i=0;var j=0
    for(l <- io.Source.fromFile(view0).getLines){
      if(i==c.i)
        for(s <- l.split(";")){
          if(j==c.j){
            Some(Number(s.toInt))
          }
          j+=1 
      }
      i+=1
    }
      None
  }
  def export():Unit={
    val tmp = new File("src/tmp.txt")
    val w = new PrintWriter(tmp)
    var i=0
    for(l <- io.Source.fromFile(view0).getLines){
      for(c <- l.split(";")){
        if(dep.isFormule(c)) {
          w.write(DataParser.formuleToString(dep.getCaseData(i))+";")
          i+=1
        }
        else w.write(c+";")
      }
      w.print("\n")
    }
    tmp.renameTo(new File(view0))
    w.close()
  }
}
