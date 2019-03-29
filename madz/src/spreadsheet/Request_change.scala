package spreadsheet

/*
 * request changement data of a case of spreedsheet
 */
abstract class Request_change(c: Case, value : CaseData)  extends Task{
  protected var sheet: Sheet_evalued = null
  def set_sheet(f :Sheet_evalued) = {sheet = f} 
}