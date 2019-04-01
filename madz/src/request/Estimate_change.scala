package request

import spreadsheet._


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
    
  def exec():Unit = { 
    val new_val = this.sheet.eval_expr(expression)
    result = estimate_update_case(case_toChange,new_val)}
  
  /*
   * precondition: a case valid c
   * c = Case(i,j) with (i:Integer) >= 0 and (j:Integer) >= 0
   * operation:
   * update case value, 
   * then update value of its dependance case
   * postcondition: return all changement on case 's value to do on the view
   */
  private def estimate_update_case(c : Case, new_val:Value) : List[Change] = { 
        val Some(init_val) = this.sheet.getValue(c)
    if (init_val == new_val) { //value of case change
      List()
    }else { //value of case no change
      //change current case et all dependanc case      
      val change_current_case = Change(c,new_val)
      val changes_all_dependance = {
        val dependances = this.sheet.getDependace(c)
        dependances.foldLeft(List[Change]())((acc, dep) => update_formule(new_val,dep) ++ acc)          
      }
      changes_all_dependance
    }
  }
  
      private def update_formule (new_val:Value, dep : Case) = {
        //calculate value of dependance
          this.sheet.formule_of(dep) match {
            case None => throw new Exception("sheet inconsistant")
            case Some( Formule(_,_,e)) => 
              new_val match {
                case VInt(new_val) => 
                  val variation_val = if (e == new_val) {1} else {-1}
                  val (dep_new_val) = new_val + variation_val
                  Change(dep, VInt(dep_new_val))::estimate_update_case(dep, VInt(dep_new_val))
                case VUncalculable() => Change(dep, VUncalculable())::estimate_update_case(dep, VUncalculable() )                  
              }
              
          }
      }
  /*
   * precondition: call this.exec() least a time
   * postcondition: return all change to do if change a case 's data
   */
  def get_result = result
    
    
}