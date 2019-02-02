import scala.io.Source

object Parser {

// Returns the List of lines contained in fileName
  private def readFile(fileName: String): List[String] = {
    return Source.fromFile(fileName).getLines.toList
  }

// Return a List in which each line contained in data turned into its splitted version
// using ";" as a separator
  private def splitData(data: List[String]): List[List[String]] = {
    var sd: List[List[String]] = Nil
    for(line <- data) { sd = line.split(";").toList :: sd }
    return sd
  }

// Returns the List of Cell corresponding to the given List of String
  private def tokenizeLine(splittedString: List[String]): List[Cell] = {
    def tokenizeLineAux(splittedString: List[String], acc: List[Cell]): List[Cell] = {
      splittedString match {
        case Nil => { return acc }
        case h::t => { return tokenizeLineAux(t, acc :+ CellFactory.create(h)) }
      }
    }
    return tokenizeLineAux(splittedString, Nil)
  }

  private def tokenize(splittedData: List[List[String]]): List[List[Cell]] = {
    def tokenizeAux(splittedData: List[List[String]], acc: List[List[Cell]]): List[List[Cell]] = {
      splittedData match {
        case Nil => { return acc }
        case h::t => { return tokenizeAux(t, tokenizeLine(h)::acc) }
      }
    }
    return tokenizeAux(splittedData, Nil)
  }

// Read the whole file and returns the corresponding Cells
  def parse(fileName: String): List[List[Cell]] = {
    return tokenize(splitData(readFile(fileName)))
  }

}
