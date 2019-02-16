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
    
  def exec():Unit = { result = estimate_update_case(case_toChange)}
  /*
   * update case value, then update value of its dependance case*/
  private def estimate_update_case(c : Case) : List[Change] = { 
    throw new Exception("no implement")
    /*
    val init_val = DataInterpreteur.evalData(c)
    val result = Interpreteur.evalData(c, c,:Int,view0:String)
    if (init != current) {
      
      this.sheet.getDependance(c).map(
      c =>     
    )}   */   
  }
  def get_result = result
    
    
}