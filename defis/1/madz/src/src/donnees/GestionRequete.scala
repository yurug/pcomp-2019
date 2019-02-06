package donnees
import java.io.File
import java.io.PrintWriter
import scala.io._
import scala.collection.mutable.ListBuffer


class GestionRequete(f:BufferedSource, i:DataInterpreteur) {
  
  def chargeRequete(): ListBuffer[Requete] = {
    val listReq = ListBuffer[Requete]()
    
    for(l <- f.getLines()){
      val r = l.split(" ")
      listReq += new Requete(new Case(r(0).toInt, r(1).toInt), DataParser.parseData(r(2)))
    }
    listReq
  }
  
  def eval_requete(r:Requete) :(Case, Option[Int])= {
    //(r.getCase,i.evalData(r.getData))
    null
	}
  
  def eval_list_req : ListBuffer[(Case,Option[Int])] = {
    val listEvalReq = ListBuffer[(Case,Option[Int])]()
    val list_req = chargeRequete()
    for(r<- list_req) listEvalReq += eval_requete(r)
    listEvalReq
  }
  
  def maj_feuille = {
  }
}