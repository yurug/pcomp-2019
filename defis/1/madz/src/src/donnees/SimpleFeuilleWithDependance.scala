

package donnees
import scala.io._

class SimpleFeuilleWithDependance(feuille:BufferedSource) extends FeuilleSimple(feuille) with FeuilleWithDependance{
  private val all_formule =  Nil
  
  def getDependance(c:Case):List[Case] = {
    def depend_by (case_target: Case ,formule :Formule) = formule match { 
      case Formule(lt,br,v) =>
      if (case_target.i <= lt.i && case_target.i >= br.i 
          && case_target.j >= lt.j && case_target.j <= br.j)
      {true}
      else {false}
    }
    all_formule.filter(depend_by(c,_))
  }
  override def loadCalc(): Unit = {
    var i=0;var j=0
    println("ok")
   for(l <- feuille.getLines()){
      println(l)
      for(c <- l.split(";")){
        val data = DataParser.parseData(c)
         data match {
          case Formule (a1,a2,a3) =>  Formule (a1,a2,a3)::all_formule
        }
        cellules(i)(j) = new Cellule( Some (data))
        j+=1
      }
      i+=1;j=0
    }
  } 
    
}