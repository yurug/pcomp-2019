package donnees

// Représentation de la feuille de calque et accès lecture écriture case par case

trait FeuilleCalque {
  def loadCalc(): Unit
  def getCell(r:Int , c:Int): Cellule
  def writeCell(r:Int, c:Int, v:String): Unit
}