trait Cell {}

class CellInt (private var entier:Int) extends Cell {
  override def toString: String = { return entier.toString }
}

class CellFormula (private var r1:Int, private var c1:Int, private var r2:Int, private var c2:Int, private var v:Int) extends Cell {
  override def toString: String = {
    return "=#(" + r1 + ", " + c1 + ", " + r2 + ", " + c2 + ", " + v + ")"
  }
}

class ErrorCell extends Cell {
  override def toString: String = { return "P" }
}


object CellFactory {

  def createCellInt(s: String): Cell = {
    try {
      var i: Int = s.toInt
      if(i <= 255 && i >= 0) { return new CellInt(i) }
      return new ErrorCell
    }
    catch {
      case e: Exception => { return new ErrorCell }
    }
  }

  def createCellFormula(s: String): Cell = {
    // val regex = "\\(|\\)|=|#|\\s|\n".r
    // var cleanedString: String = regex.replaceAllIn(s, "")
    // var cleanedString: String = s.replaceAll("\\s | \\( | \\) | = | #", "")
    var cleanedString: String = s.replaceAll("\\s", "")
    cleanedString = cleanedString.replaceAll("\\(", "")
    cleanedString = cleanedString.replaceAll("\\)", "")
    cleanedString = cleanedString.replaceAll("=", "")
    cleanedString = cleanedString.replaceAll("#", "")
    var ss: Array[String] = cleanedString.split(",")
    try {
      if(ss.length == 5 && ss(0) <= ss(2) && ss(1) <= ss(3)) { return new CellFormula(ss(0).toInt, ss(1).toInt, ss(2).toInt, ss(3).toInt, ss(4).toInt) }
      return new ErrorCell
    }
    catch {
      case e: Exception => { return new ErrorCell }
    }
  }

  def create(s: String): Cell = {
    if(s.startsWith("=#")) { return createCellFormula(s) }
    else if(s.matches("[0-9]+")) { return createCellInt(s) }
    return new ErrorCell
  }

}


class Operation (private var cel: Cell ) {}
