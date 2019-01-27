package evaluateur
import donnees._
// object contenant méthodes d'évluations de formules

object FormuleEval {
  
  def isAllDigits(x: String) = x forall Character.isDigit
  
  def evalFormule(r1:Int, c1:Int, r2:Int, c2:Int, 
      v:Int, cellules:Array[Array[Cellule]]):Option[Int] ={
    var nbrv=0
    for( i <- r1 to r2){
      for( j <- c1 to c2){
        if(!isAllDigits(cellules(i)(j).getV()))
          return None
        else if(cellules(i)(j).getV().equals(v+""))
          nbrv+=1
      }  
    }
    Some(nbrv)
  }
}