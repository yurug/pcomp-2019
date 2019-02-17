package donnees

import java.io.File

import java.io.PrintWriter

object DataInterpreteur {
  val database = "view0.txt"
  
  def getEvalRegionV0(c1:Case, c2:Case,v:Int,view0:String):CaseData={
    var count=0
    var i=0;var j=0
    for(l <- io.Source.fromFile(view0).getLines){
      if(c1.i<=i && i<=c2.i)
        for(c <- l.split(";")){
          if(c1.j<=j && j<=c2.j)
            if (c.equals(v+"")) count+=1
          j+=1
        }
      i+=1;j=0
    }
    Number(count)
  }
  
  def getEvalRegionV1(id:Int,v:Int):CaseData={
    var count=0
    for(l <- io.Source.fromFile(id+"").getLines){
       val lignelist =l.split(" ")
       count+=lignelist.filter(_ == v).size
    }
    Number(count)
  }
  
  //def getValueData (c: Case): CaseData = get_FormuleId 
  def evalData(data :CaseData) = data match {
    case Number(n) =>  Number(n)
    case Formule(lt,br,v) => getEvalRegionV0(lt, br, v,database)
			case _ => P()
  }
    
   // getEvalRegionV0(c,c,v,database)
  /*
  
  
	
	 def writeView(view:String):Unit ={
     val writer = new PrintWriter(new File(view))
     for(l <- fs.getFeuille){
       var list= l.map (c => DataParser.formuleToString(c.getVal))
        writer.write(list.mkString(";"))
        writer.write("\n")
     }
    writer.close()
   }
				*/
}