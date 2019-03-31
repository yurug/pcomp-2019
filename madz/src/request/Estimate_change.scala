package request

import spreadsheet.Case
import spreadsheet.CaseData
import spreadsheet.Sheet_evalued
import spreadsheet.Value

case class Change(case_toChange:Case,value: Value)

/*
 * estimate changement to do for execution of a request change
 */
class Estimate_change(case_toChange: Case, expression : CaseData) 
extends Request_change(case_toChange, expression){ 
  
  protected var result: List[Change] = Nil 
  
  def this (c: Case, value : CaseData, sheet: Sheet_evalued) =
    this(c, value)
    this.set_sheet(sheet)
    
  def exec():Unit = { result = estimate_update_case(case_toChange,expression)}
  
  /*
   * precondition: a case valid c
   * c = Case(i,j) with (i:Integer) >= 0 and (j:Integer) >= 0
   * operation:
   * update case value, 
   * then update value of its dependance case
   * postcondition: return all changement on case 's value to do on the view
   */
  private def estimate_update_case(c : Case, expr:CaseData) : List[Change] = { 
    val init_val = this.sheet.getValue(c)
    val current_val = this.sheet.eval_expr(expr) 
    if (init_val == current_val) {
      List()
    }else {
      //change current case et all dependanc case      
      val change_current_case = Change(c,current_val)
      val changes_all_dependance = {
        val dependances = this.sheet.getDependace(c)
        dependances.map( c =>
            
        )
      }
      change_current_case::changes_all_dependance
    }
  }
  
  /*
   * precondition: call this.exec() least a time
   * postcondition: return all change to do if change a case 's data
   */
  def get_result = result
    
    
}