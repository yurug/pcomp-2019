package csv_preprocessor

import change._
import utils._
import cell_parser._
import scala.util.{Try, Success, Failure}

/** Preprocess a CSV file to simplify the future evaluation.
  * Here, compute the initial value for each formulae counting
  * the ACell of the file.
  * For all AChange, its oldValue is replaced by the value at this position
  * in the file.
  * After that, there is no longer need for the file.
  *
  *
  * To avoid to check for all the Changes if a cell affects it, we sort the
  * BChanges by the position of their top-left corner. Then, as we go through
  * the cell in the lexicographic order (x, y) (the normal order), for each cell,
  * we can't stop to see the BChanges when we reach a BChange with a top-left
  * after the position of the cell. And when we reach the cell at the position
  * (x, y), all the BChanges with a bottom-right corner before this position
  * would not be affected by any cell that we process after.
  */
object CSVPreProcessor {

  /** Propagate the value of a cell in a list of BChange.
    * If a BChange depends on the cell and the number that it counts
    * is the value of the cell, then increment the valueWithInitialA of this
    * change.
    *
    * @param p The position of the cell.
    * @param v The value of the cell.
    * @param bcs The list of BChange which could be impacted.
    * @return The list of BChange which could be impacted by the following cell.
    */
  private def propagateInB(
      p: Position,
      v: Int,
      bcs: List[BChange]): List[BChange] = bcs match {
    case Nil => Nil
    case bc::q =>
      if(bc.b.isAfter(p))
        return bcs
      else if(p > bc.b.bottomRight)
        return propagateInB(p, v, q)
      else if(bc.b.contains(p) && bc.counted == v) {
        bc.valueWithInitialA += 1
        if(bc.b.bottomRight.equals(p))
          return propagateInB(p, v, q)
      }
      return bc :: propagateInB(p, v, q)
  }

  /** Propagate the value of a cell in all the changes. Of course, propagate
    * only the value of the cell of type A.
    *
    * @param c The change associeted to the cell.
    * @param p The position of the cell.
    * @param bcs The list of BChange which could be affected by `c`.
    *
    * @return The list of BChange and AChange that could be impacted by the
              following cells.
    */
  private def propagateCell(
      c: Change,
      p: Position,
      bcs: List[BChange]): List[BChange] = c match {
    case _: AChange => propagateInB(p, c.v, bcs)
    case _          => return bcs
  }

  /** Propagate all the values of the cells of a line in all the changes.
    *
    * @param cellsWithY The cells to process with value and y position.
    * @param x The x position of the line to process.
    * @param bcs The list of BChange which could be affected by the cells of
                 this line.
    *
    * @return The list of BChange and AChange that could be impacted by the
              following lines.
    */
  private def processLine(
      cellsWithY: Iterator[(String, Int)],
      x: Int,
      bcs: List[BChange]): List[BChange] = {
    if(bcs.isEmpty || cellsWithY.isEmpty) {
      return bcs
    }
    val (cell, y): (String, Int) = cellsWithY.next
    val p: Position = new Position(x, y)
    val c: Change = CellParser.parse(x, y, cell)
    val fr: List[BChange] = propagateCell(c, p, bcs)
    processLine(cellsWithY, x, fr)
  }

  /** Propagate all the values of the cells of some lines in all the changes.
    *
    * @param linesWithY The lines to process with value and y position.
    * @param bcs The list of BChange which could be affected by the cells.
    */
  private def process(
      linesWithX: Iterator[(String, Int)],
      bcs: List[BChange]): Unit = {
    if(bcs.isEmpty || linesWithX.isEmpty) {
      return
    }
    val (str, x) = linesWithX.next
    val cellsWithY: Iterator[(String, Int)] =
      str.split(";").iterator.zipWithIndex
    val fr: List[BChange] = processLine(cellsWithY, x, bcs)
    println(x)
    process(linesWithX, fr)
  }

  /** Count the initial value of BChanges, that is to say, the value that they
    *are by only considering the cell of type A in the file.
    *
    * @param file The CSV file to process.
    * @param bcs The list of BChange whose initial value should be computed
                 (assume they are sorted bu block position).
    */
  def countInitialValues(file: io.BufferedSource, bcs: List[BChange]): Unit = {
    if(bcs.isEmpty)
      return
    val linesWithX = file.getLines.zipWithIndex
    linesWithX.drop(bcs.head.b.topLeft.x)
    process(linesWithX, bcs)
  }


  def computeInitialValue(
      c: BChange,
      csv: io.BufferedSource,
      old: List[AChange]): Unit = {
    val lines: Iterator[(String, Int)] = csv.getLines.zipWithIndex
    var changes: List[AChange] =
      old.sortBy {ac => (ac.p.x, ac.p.y) }.filter { ac => c.b.contains(ac.p) }
    lines.drop(c.b.topLeft.x).take(c.b.bottomRight.x - c.b.topLeft.x + 1)
    lines.foreach { elem =>
      val (line, x) = elem
      while(!changes.isEmpty && (changes.head.p.x < x))
        changes = changes.tail
      val cells = line.split(";")
      for(y <- c.b.topLeft.y to c.b.bottomRight.y) {
        while(!changes.isEmpty && changes.head.p.x == x && changes.head.p.y < y)
          changes = changes.tail
        if(!changes.isEmpty && changes.head.p.equals(c.p)) {
          if(changes.head.v == c.counted)
            c.valueWithInitialA += 1
          changes = changes.tail
        }
        else {
          Try(cells(y).toInt) match {
            case Failure(_) => ()
            case Success(v) =>
              if(v == c.counted)
                c.valueWithInitialA += 1
          }
        }
      }
    }
  }

}
