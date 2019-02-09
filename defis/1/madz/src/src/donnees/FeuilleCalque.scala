package donnees

// Représentation de la feuille de calque et accès lecture écriture case par case
trait FeuilleCalque {
  def copyF():Unit 
  def copyligne(s:String,numligne:Int):String
  def getView():String
  def getdata():String
  def getCaseData(id:Int):CaseData
  
}