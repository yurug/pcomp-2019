trait Cell {
  // def create(s: String): Cell
}

class CellInt (private var entier:Int) extends Cell {
  // def create(s: String): Cell = {
  //   var i: Int = s.toInt
  //   if(i <= 255 && i >= 0) { return new CellInt(i) }
  //   return new ErrorCell
  // }
}

class CellFormula (private var r1:Int, private var r2:Int, private var c1:Int, private var c2:Int, private var v:Int) extends Cell {
  // def create(s: String): Cell = {
  //   var cleanedString: String = s.replaceAll("(|)|=|#|\\s", "")
  //   var ss: Array[String] = s.split(",")
  //   if(ss.length == 5) { return new CellFormula(ss(0).toInt, ss(1).toInt, ss(2).toInt, ss(3).toInt, ss(4).toInt) }
  //   return new ErrorCell
  // }
}

class ErrorCell extends Cell {
  // def create(s: String): Cell = { return new ErrorCell }
}


object CellFactory {

  def create(s: String): Cell = {
    try {
      // if(s.startsWith("=#")) { return CellFormula.create(s) }
      // else if(s.matches("[0-9]+")) { return CellInt.create(s) }
      if(s.startsWith("=#")) {
        var cleanedString: String = s.replaceAll("(|)|=|#|\\s", "")
        var ss: Array[String] = s.split(",")
        if(ss.length == 5) { return new CellFormula(ss(0).toInt, ss(1).toInt, ss(2).toInt, ss(3).toInt, ss(4).toInt) }
      }
      else if(s.matches("[0-9]+")) {
        var i: Int = s.toInt
        if(i <= 255 && i >= 0) { return new CellInt(i) }
      }
      return new ErrorCell
    }
    catch {
      case e: Exception => { return new ErrorCell }
    }
  }

}


class Operation (private var cel: Cell ) {}
