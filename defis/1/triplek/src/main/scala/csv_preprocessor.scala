package csv_preprocessor

import change._
import utils._
import cell_parser._

/** Preprocess a CSV file to simplify the future evaluation.
  * Here, compute the initial value for each formulae couting
  * the ACell of the file.
  * For all AChange, its oldValue is replaced by the value at this position
  * in the file.
  * After that, there is no longer need for the file.
  *
  *
  * To avoid to check for all the Changes if a cell affects it, we sort the
  * BChanges by the position of their top-left corner. Then, as we go through
  * the cell in the lexicographic order (x, y) (the normal order), for each cell,
  * ce can't stop to see the BChanges when we reach a BChange with a top-left
  * after the position of the cell. And when we reach the cell at the position
  * (x, y), all the BChanges with a bottom-right corner before this position
  * would not be affected by any cell that we process after
  *Z
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
      }
      return bc :: propagateInB(p, v, q)
  }

  /** Change the oldValue of AChanges which are at the position of a cell
    * by the value of the cell.
    *
    * @param p The position of the cell.
    * @param v The value of the cell.
    * @param acs The list of AChange which could be impacted.
    *
    * @return The list of BChange that could be impacted by the following cells.
    */
  private def propagateInA(
      p: Position,
      v: Int,
      acs: List[AChange]): List[AChange] = acs match {
    case Nil => Nil
    case ac::q =>
      if(ac.p > p)
        return acs
      else if(ac.p.x == p.x && ac.p.y == p.y) {
        ac.valueWithInitialA = v
      }
      return propagateInA(p, v, q)
  }

  /** Propagate the value of a cell in all the changes. Of course, propagate
    * only the value of the cell of type A.
    *
    * @param c The change associeted to the cell.
    * @param p The position of the cell.
    * @param bcs The list of BChange which could be affected by `c`.
    * @param acs The list of AChange which could be affected by `c`.
    *
    * @return The list of BChange and AChange that could be impacted by the
              following cells.
    */
  private def propagateCell(
      c: Change,
      p: Position,
      bcs: List[BChange],
      acs: List[AChange]): (List[BChange], List[AChange]) = c match {
    case _: BChange => return (bcs, acs)
    case _: AChange => (propagateInB(p, c.v, bcs), propagateInA(p, c.v, acs))
  }

  /** Propagate all the values of the cells of a line in all the changes.
    *
    * @param cellsWithY The cells to process with value and y position.
    * @param x The x position of the line to process.
    * @param bcs The list of BChange which could be affected by the cells of
                 this line.
    * @param acs The list of AChange which could be affected by the cells of
                 this line.
    *
    * @return The list of BChange and AChange that could be impacted by the
              following lines.
    */
  private def processLine(
      cellsWithY: Iterator[(String, Int)],
      x: Int,
      bcs: List[BChange],
      acs: List[AChange]): (List[BChange], List[AChange]) = {
    if((bcs.isEmpty && acs.isEmpty) || cellsWithY.isEmpty) {
      return (bcs, acs)
    }
    val (cell, y): (String, Int) = cellsWithY.next
    val p: Position = new Position(x, y)
    val c: Change = CellParser.parse(x, y, cell)
    val (fr, ar): (List[BChange], List[AChange]) = propagateCell(c, p, bcs, acs)
    processLine(cellsWithY, x, fr, ar)
  }

  /** Propagate all the values of the cells of some lines in all the changes.
    *
    * @param linesWithY The lines to process with value and y position.
    * @param bcs The list of BChange which could be affected by the cells.
    * @param acs The list of AChange which could be affected by the cells.
    */
  private def process(
      linesWithX: Iterator[(String, Int)],
      bcs: List[BChange],
      acs: List[AChange]): Unit = {
    if((bcs.isEmpty && acs.isEmpty) || linesWithX.isEmpty) {
      return
    }
    val (str, x) = linesWithX.next
    val cellsWithY: Iterator[(String, Int)] =
      str.split(";").iterator.zipWithIndex
    val (fr, ar): (List[BChange], List[AChange]) =
      processLine(cellsWithY, x, bcs, acs)
    process(linesWithX, fr, ar)
  }

  /** Count the initial value of AChanges and BChanges, that is to say,
    * the value that they are by only considering the cell of type A in the
    * file.
    *
    * @param file The CSV file to process.
    * @param bcs The list of BChange whose initial value should be computed.
    * @param acs The list of AChange whose initial value should be computed.
    */
  def countInitialValues(
      file: io.BufferedSource,
      bcs: List[BChange],
      acs: List[AChange]) = {
    val sortedAcs: List[AChange] = acs.sortBy(c => (c.p.x, c.p.y))
    val sortedBcs: List[BChange] = Change.sortByBlockPosition(bcs)
    val linesWithX = file.getLines.zipWithIndex
    process(linesWithX, sortedBcs, sortedAcs)
  }

}
