package donnees

class Estimate_change(case_toChange: Case, expression : CaseData) 
extends Request_change(case_toChange, expression){ 
  
  def this (c: Case, value : CaseData, sheet: FeuilleCalque) =
    this(c, value)
    this.set_sheet(sheet)
    
  def exec():Unit = { update_case(case_toChange)}
  /*
   * update case value, then update value of its dependance case*/
  private def update_case(c : Case) = { /*
    val init_val = DataInterpreteur.evalData(c)
    val result = Interpreteur.evalData(c, c,:Int,view0:String)
    if (init != current) {
      
      this.sheet.getDependance(c).map(
      c =>     
    )}   */   
  }
  def result_exec():String = ""  
}