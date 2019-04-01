package spreadsheet

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
    for ((id0,(f,l)) <- listFormule){
      var ll=List[Int]()
      for((id1,Case(x,y))<- listCoord)
        if(id0!=id1){
          f.get_expression match {
            case Formule(Case(r1,c1),Case(r2,c2),v) =>
              if(r1<=x && x<=r2 && c1<=y && y<=c2){
                ll=id1::ll
              }
            case _ =>Nil
          }
      }
      addDep(id0,ll)
    }
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
     for ((id,(content,l)) <- listFormule)       
       if (l==Nil){
         val Formule(c1,c2,v) = content.get_expression
         content.set_value(DataInterpreteur.getEvalRegionV0(c1,c2,v,fs.getView))
         SuppDependance(id) //remove direct cycle
         i+=1
       }
     if(i!=0) eval_calculable_formule()
  }
  
  /*
   * precondition: graph with node with cycle in graph
   * operation: put calculate value of all incalculable formule
   * postcondition: graph with incalculable formule
   */    
  private def eval_incalculable_formule():Unit={
      for ((k,(f,l)) <- listFormule)
        f.set_value(VUncalculable())
  }
  
  private def eval_formules = {
    eval_calculable_formule()
    eval_incalculable_formule()    
  }

  def is_formule(c:Case) = get_FormuleId(c) match{
    case None => false
    case Some(_) => true
  }
}