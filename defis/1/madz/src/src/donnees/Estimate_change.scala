package donnees

case class Change(case_leftTop:Case, 
	case_bottomRight:Case,
	value: Value)
	
	class Estimate_change(case_toChange: Case, expression : CaseData) 
extends Request_change(case_toChange, expression){ 
  
  protected var result: List[Change] = Nil 
  
  def this (c: Case, value : CaseData, sheet: FeuilleCalque) =
    this(c, value)
    this.set_sheet(sheet)
    
  def exec():Unit = { 
    val init_val = DataInterpreteur.evalData(expression)
    update_case(case_toChange,init_val)}
  /*
   * update case value, then update value of its dependance case*/
  private def update_case(c : Case, value : CaseData) = {     
    /*val result = Interpreteur.evalData(c, c,:Int,view0:String) //PROBLEM je veux la valeur de case c, pour comparer avec new valeur,et decider lancer update ou non
    if (init != current) {
      
      this.sheet.getDependance(c).map(
      c =>     
    )}   */   
  }
  def get_result = result
    
    
}