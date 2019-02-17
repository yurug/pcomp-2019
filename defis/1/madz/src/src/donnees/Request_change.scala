package donnees

abstract class Request_change(c: Case, value : CaseData)  extends Task{
  protected var sheet: FeuilleCalque = null
  protected var sheet_evalued : Sheet_evalued = null
  def set_sheet(f :FeuilleCalque) = {sheet = f} 
  def set_sheet_evalued(f :Sheet_evalued) = {sheet_evalued = f}
  
  
}