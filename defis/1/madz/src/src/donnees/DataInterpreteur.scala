package donnees

import java.io.File
import java.io.PrintWriter

class DataInterpreteur(fs:FeuilleSimple) {
  
  
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
				
}