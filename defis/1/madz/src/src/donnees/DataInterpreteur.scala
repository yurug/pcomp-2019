package donnees

import java.io.File
import java.io.PrintWriter

object DataInterpreteur {
  private val database = "view0.txt"  
  
  def getEvalRegionV0(c1:Case, c2:Case,v:Int,view0:String):CaseData={
    var count=0
    val out = new java.io.BufferedWriter( new java.io.FileWriter(view0) );
    var i=0;var j=0
    for(l <- io.Source.fromFile(view0).getLines){
      if(c1.i<=i && i<=c2.i){
        for(c <- l.split(";")){
          if(c1.j<=j && j<=c2.j){
            if (c.equals(v)) count+=1
          }else j+=1
        }
      }else i+=1
    }
    Number(count)
  }
  //def getValueData (c: Case): CaseData = get_FormuleId 
    
    
   // getEvalRegionV0(c,c,v,database)
  /*
  def evalData (data: Option[CaseData]): CaseData ={
    data match  {
			case Some (Number (n)) => Number(n)
			case Some (Formule (lt,br,v)) => fs.getEvalRegion(lt, br, v)
			case _ => P()
		}
		
	}

	def evalCellules() :Unit= {
		var i=0;var j=0
    for(l <- fs.getFeuille){
      for(c <- l){
         fs.writeCell(Case(i,j), evalData(c.getVal)) 
         j+=1
      }
      i+=1;j=0
    }
  }
	
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