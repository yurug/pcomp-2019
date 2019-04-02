package spreadsheet
import util._

class Formule_graph extends Graph[Formule_node,Connection[Formule_node]]{
  protected var graph_formule = scala.collection.mutable.Map[Formule_node,List[Formule_node]]()

  def add_formule(f:Formule,numligne: Int ,numcol: Int) = {    
    var node = new Formule_node()
    node.set_expression(f)
    node.set_position(Case(numligne,numcol))    
    this.addNode(node)    
  }
  
  def isFormule(c:String):Boolean = {
    println(c+" "+c.toInt)
    return this.getNodes.size > c.toInt
  }  
  def all_node = this.getNodes     


  def expression_of_formule_in(c:Case):Formule ={ node_of_formule(c).get_expression} 

  
  
         /*
          * precondition: case of a formule
          * postcondition: node of formule in dependancie graph
          */
          def node_of_formule(c:Case):Formule_node = {
           def node_match_case (n:Formule_node,c:Case) = if (n.get_position == c) { true} else { false}
           try{
             graph_formule.keys.filter(node_match_case(_,c)).head  
           }catch{
             case _ => throw new Exception("case" +Printer.toString(c)+"no contain formule")
             }
             
           }

         }