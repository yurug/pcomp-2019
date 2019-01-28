package donnees


import evaluateur._

object DataParser{
  
  def isAllDigits(x: String) = x forall Character.isDigit

  
  def parseData(data : String):CaseData={ 
    val dateREGX = "=#\\((\\d+),(\\d+),(\\d+),(\\d+),(\\d+))".r    	
    isAllDigits (data) match {  
      case true => Number (data.toInt)
      case false => 
        data match{
          case dateREGX(r1,r2,c1,c2,v)=> 
            Formule (Case(r1.toInt,c1.toInt),Case(r2.toInt,c2.toInt),v.toInt)
          case _ => P()
      }
    }
  }
  
   def formuleToString(cellules: Array[Array[Cellule]]):Unit={
    var i=0
    var j=0
    for(l <- cellules){
      for(c <- l){
        c.getVal match {
        case Number(n) => cellules(i)(j)=new Cellule(new Number(n+"".toInt))
        case Formule(r,c,v) => 
          FormuleEval.evalFormule(r,c,v,cellules) match {
            case None => cellules(i)(j)=new Cellule(P())
            case Some(n)=> cellules(i)(j)=new Cellule(new Number(n+"".toInt))
          }
       case P() => cellules(i)(j)=new Cellule(P())
       
      }
        j+=1
     }
      i+=1
    }
  }
}