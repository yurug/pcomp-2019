package spreadsheet

import util.Connection

/*
 * detect if exist a cycle between set of formule
 */
 class FormuleEvaluator(fs:Sheet_evalued_Impl)
 extends Formule_graph{

  def start_evaluation = {
    build_dependancie_between_formule()
    eval_formules
  }

  /*
   * precondition:a graph of formlule with node no connected between them
   * operation:for all node,connect node A to B if formule A dependant formule B
   * postcondition: dependancie graph of formule 
   */
   private def build_dependancie_between_formule():Unit={
    def build_dependancie_between_2_formule (n:Formule_node,n2:Formule_node) = {
      val f = n.get_expression
      val p = n.get_position
      if( FormuleEvaluator.depend(f,p)) {
        this.addLink(new Connection(n,n2))
      }else{}
    }
    def build_all_dependancie_of_formule (n:Formule_node) = this.getNodes.map( build_dependancie_between_2_formule(n,_))
    this.getNodes.map( build_all_dependancie_of_formule)
  }
  

  /*
   * precondition: graph 
   * operation: 
   * evaluation calculable formule value
   * deleted all node without cycle in graph
   * postcondition: graph with node with cycle in graph
   */  
   private def eval_calculable_formule():Unit={
    var i=0
    for (content <- this.getNodes)       
     if (neighbour_of(content) == Nil){
       val Formule(c1,c2,v) = content.get_expression
       content.set_value(DataInterpreteur.getEvalRegionV0(c1,c2,v,fs.getView))
       rm_all_dependancie_on(content) //remove direct cycle
       i+=1
     }
     if(i!=0) eval_calculable_formule()
   }
 
  /*
   * delete all connection pointed on node n 
   */
   private def rm_all_dependancie_on(n: Formule_node):Unit = {
    def is_pointed_on (connect : Connection[Formule_node], target: Formule_node) = {
      val Connection(src, t) = connect
      t == target
    }
    this.getLinks.filter(is_pointed_on(_,n))
  }
  /*
   * precondition: graph with node with cycle in graph
   * operation: put calculate value of all incalculable formule
   * postcondition: graph with incalculable formule
   */    
   private def eval_incalculable_formule():Unit={
    this.getNodes.map(
      f => f.set_value(VUncalculable()))  
  }
  
  private def eval_formules = {
    eval_calculable_formule()
    eval_incalculable_formule()    
  }

  def is_formule(c:Case) = {
    this.getNodes.exists(n => n.get_position == c)
  }

  
}
object FormuleEvaluator{
  def depend(f:Formule, c:Case) = {
   val Formule(Case(i1,j1),Case(i2,j2),v) = f
   val Case(i,j) = c
   if( between(i1,i2,i) && between(j1,j2,j)){
     true  
   } else { false}     
 }
 private def between(down:Int,up:Int,v:Int) = 
   if (v <= up && v >= up) { true}
 else {false}
 

}