package donnees

class Estimate_change(c: Case, value : CaseData) 
extends Request_change(c, value){ 
  
  def this (c: Case, value : CaseData, sheet: FeuilleCalque) =
    this(c, value)
    this.set_sheet(sheet)
    
  def exec():Unit = {
    /*eval case, update dependance, if val change
     * continue update*/
    
  }
  /*
   * update case value, then update value of its dependance case*/
  private def update_case(c: Case, init:CaseData, current:CaseData) = {
    val result = DataInterpreteur.getEvalRegionV0(c, c,:Int,view0:String)
    if (init != current) {
      
      this.sheet.getDependance(c).map(
      c =>     
    )}      
  }
  def result_exec():String = ""  
}