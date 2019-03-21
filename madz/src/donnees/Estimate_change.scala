package donnees

case class Change(case_leftTop:Case, 
	case_bottomRight:Case,
	value: Value)

/*
 * estimate changement to do for execution of a request change
 */
class Estimate_change(case_toChange: Case, expression : CaseData) 
extends Request_change(case_toChange, expression){ 
  
  protected var result: List[Change] = Nil 
  
  def this (c: Case, value : CaseData, sheet: Sheet_evalued) =
    this(c, value)
    this.set_sheet(sheet)
    
  def exec():Unit = { result = estimate_update_case(case_toChange)}
  
  /*
   * precondition: a case valid c
   * c = Case(i,j) with (i:Integer) >= 0 and (j:Integer) >= 0
   * operation:
   * update case value, 
   * then update value of its dependance case
   * postcondition: return all changement on case 's value to do on the view
   */
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
  
  /*
   * precondition: call this.exec() least a time
   * postcondition: return all change to do if change a case 's data
   */
  def get_result = result
    
    
}