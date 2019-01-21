package donnees

// Représentation de la feuille de calque et accès lecture écriture case par case

trait FeuilleCalque {
  def loadCalc(file:String): Unit
  def getCell(r:Int , c:Int): Cellule
  def writeCell(r:Int, c:Int, v:Int): Unit
}