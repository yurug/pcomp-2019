package donnees

abstract class Request_change(c: Case, value : CaseData)  extends Task{
  protected var sheet: FeuilleCalque = null
  def set_sheet(f :FeuilleCalque) = {sheet = f} 
}