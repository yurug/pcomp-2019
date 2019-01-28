class Parser {

  def splitData(data: String): String[] = {
    return data.split(";")
  }

  def makeCellInt(s: String): Cell = {
    try {
      var i: Int = s.toInt
      if(i <= 255 && i >= 0) { return new CellInt(i) }
      return new ErrorCell
    }
    catch {
      case e: Exception => { return new ErrorCell }
    }
  }

  def makeCellFormule(s: String): Cell = {
    if(s.endsWith(")")) {
      var cleanedString = s.subString(3, s.length() - 2)
      cleanedString = cleanedString.replaceAll(" ", "")
      var ss = s.split(",")
      if(l.length == 5) {
        var r1, c1, r2, c2, v, i: Int = 0
        for(i <- 0 until 5) {
          try {
            i match {
              case 0 => r1 = ss[i].toInt
              case 1 => c1 = ss[i].toInt
              case 2 => r2 = ss[i].toInt
              case 3 => c2 = ss[i].toInt
              case 4 => v = ss[i].toInt
            }
          }
          catch {
            case e: Exception => { return new ErrorCell }
          }
        }
        return new CellFormule(r1, c1, r2, c2, v)
      }
    }
    return new ErrorCell
  }

  def tokenize(data: List[String], acc: List[Cell]): List[Cell] = {
    data match {
      case Nil => { return acc }
      case h::t => {
        if(s.startsWith("=#(")) { cell = makeCellFormule(s) }
        else { cell = makeCellInt(s) }
        return tokenize t cell::acc
      }
    }
  }

  def parse(data: String) {
    splitData: String[] =  splitData(data)
    return tokenize data Nil
  }

}
