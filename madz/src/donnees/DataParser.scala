package donnees

/*
 * parse data file
 */
object DataParser{
  
  
  def isAllDigits(x: String) = x forall Character.isDigit
  
  def parseData(data : String):CaseData={ 
    val dateREGX = "\\=\\#\\((\\d+), (\\d+), (\\d+), (\\d+), (\\d+)\\)".r    	
    isAllDigits (data) match {  
      case true =>if (data.toInt<256)  Number(data.toInt) else P()
      case false =>
        data match{
          case dateREGX(r1,c1,r2,c2,v)=>
            Formule (Case(r1.toInt,c1.toInt),Case(r2.toInt,c2.toInt),v.toInt)
          case _ => P()
        }
    }
  }
 
  def formuleToString(datacase:CaseData):String={
    datacase match{
      case Number(n) => n+""
      case P() => "P"
      case _ => "P"
    }
  }
     
   
}