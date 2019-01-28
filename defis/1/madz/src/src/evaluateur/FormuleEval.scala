package evaluateur
import donnees._
// object contenant méthodes d'évluations de formules

object FormuleEval {
  
  def isAllDigits(x: String) = x forall Character.isDigit
  
  def evalFormule(cl:Case,cr:Case,v:Int, 
      cellules: Array[Array[Cellule]]):Option[Int] ={
    var nbrv=0
    for( i <- cl.i to cr.i){
      for( j <- cl.j to cr.j){
        if(!isAllDigits(cellules(i)(j).getVal+""))
          return None
        else if(cellules(i)(j).getVal.equals(v+""))
          nbrv+=1
      }  
    }
    Some(nbrv)
  }
  
 
  
}