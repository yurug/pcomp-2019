package donnees

case class Change(c:Case,value: Value)
	
	class Estimate_change(case_toChange: Case, expression : CaseData) 
extends Request_change(case_toChange, expression){ 
  
  protected var result: List[Change] = Nil 
  

  def this (c: Case, value : CaseData, s: Sheet_evalued,sheet: FeuilleCalque) = {
    this(c, value)
    this.set_sheet_evalued(s) 
    this.set_sheet(sheet)
  }

    
  def exec():Unit = { 
    val init_val = this.sheet_evalued.evalData(expression)
    result = update_case(case_toChange,init_val)}
  /*
   * list of to update case and its value, then update value of its dependance case*/
  private def update_case(c : Case, value : Value): List[Change] = {     
    val Some(val_current_case) = this.sheet_evalued.getValueData(c) 
    if (value != val_current_case){
      val changes_dependance = this.sheet_evalued.getDependance(c).map(
          formule => update_case(formule, 
              sheet_evalued.update_formule(formule, value))
          )
      changes_dependance.flatten   
    }
    else{Nil}  
  }
  def get_result = result
    
    
}