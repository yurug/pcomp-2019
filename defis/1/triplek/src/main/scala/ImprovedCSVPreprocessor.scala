/** In fact, not really faster than CSVPreProcessor (because Array instead of
    List?). But, we keep itbecause some ideas use for the algorithm are good and
    change be used to improve the CSVPreProcessor if necesary. However, with
    around 1000 formulas and a file of 1.5 Go, it does not take too much time
    (a little less than ten minutes). 

 */


package improved_csv_preprocessor

import change._
import utils._
import cell_parser._
import scala.util.{Try, Success}
import scala.math.max

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
  /*private def propagateInB(
      p: Position,
      v: Int,
      bcs: List[BChange]): List[BChange] = bcs match {
    case Nil => Nil
    case bc::q =>
      if(bc.b.topLeft > p) {
        return bcs
      }
      else if(p > bc.b.bottomRight || p == bc.b.bottomRight)
        return propagateInB(p, v, q)
      else if(bc.b.contains(p) && bc.counted == v) {
        bc.valueWithInitialA += 1
      }
      return bc :: propagateInB(p, v, q)
  }*/

  def propagateInB(p: Position, v: Int, l: Array[BChange], minX: Int, topL: Array[Position]): Int = {
    var min: Int = minX
    var i: Int = minX
    while(i < l.size && p > l(i).b.bottomRight) {
      i += 1
    }
    while(i < l.size && p == l(i).b.bottomRight) {
      if(l(i).counted == v) {
        l(i).valueWithInitialA += 1
      }
      i += 1
    }
    min = i
    for(i <- min until l.size) {
      if(topL(i) > p) {
        return min
      }
      else if(l(i).b.contains(p) && l(i).counted == v) {
        l(i).valueWithInitialA += 1
      }
    }
    return min
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
  private def propagate(
      p: Position,
      v: Int,
      cs: Array[Change],
      i_min: Int): Int = {
    var min: Int = i_min
    var i: Int = i_min
    while(i < cs.size && cs(i).p.x == p.x && cs(i).p.y == p.y) {
      cs(i).oldValue = v
      i += 1
    }
    return i
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
      cells: Iterator[String],
      x: Int,
      y: Int,
      bcs: Array[BChange],
      minX: Int,
      topL: Array[Position],
      acs: Array[Change],
      minA: Int): (Int, Int) = {
    if((minX >= bcs.size && minA >= acs.size) || cells.isEmpty) {
      return (minX, minA)
    }
    val cell: String = cells.next
    val p: Position = new Position(x, y)
    Try(cell.toInt) match {
      case Success(v) =>
        val min: Int = propagateInB(p, v, bcs, minX, topL)
        val min2: Int = propagate(p, v, acs, minA)
        processLine(cells, x, y + 1, bcs, min, topL, acs, min2)
      case _ => processLine(cells, x, y + 1, bcs, minX, topL, acs, minA)
    }
  }

  /** Propagate all the values of the cells of some lines in all the changes.
    *
    * @param linesWithY The lines to process with value and y position.
    * @param bcs The list of BChange which could be affected by the cells.
    * @param acs The list of AChange which could be affected by the cells.
    */
  private def process(
      lines: Iterator[String],
      x: Int,
      bcs: Array[BChange],
      minX: Int,
      topL: Array[Position],
      acs: Array[Change],
      minA: Int): Unit = {
    if((minX >= bcs.size && minA >= acs.size) || lines.isEmpty) {
      return
    }
    val str: String = lines.next
    val cells: Iterator[String] = str.split(";").iterator
    val (min, min2): (Int, Int) = processLine(cells, x, 0, bcs, minX, topL, acs, minA)
    process(lines, x + 1, bcs, min, topL, acs, min2)
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
      acs: List[Change]) = {
    val sortedAcs: Array[Change] = acs.toArray.sortBy(c => (c.p.x, c.p.y))
    val sortedBcs: Array[BChange] = Change.sortByBlockPosition(bcs.toArray)
    var topL: Array[Position] = computeTopLeft(sortedBcs)
    val lines = file.getLines
    process(lines, 0, sortedBcs, 0, topL, sortedAcs, 0)
  }

  def computeTopLeft(l: Array[BChange]): Array[Position] = {
    if(l.isEmpty) {
      return new Array[Position](0)
    }
    val topL: Array[Position] = new Array[Position](l.size)
    topL(l.size - 1) = l(l.size - 1).b.topLeft
    for(i <- l.size - 2 to 0 by -1) {
      if(l(i).b.topLeft > l(i + 1).b.topLeft) {
        topL(i) = l(i + 1).b.topLeft
      }
      else {
        topL(i) = l(i).b.topLeft
      }
    }
    return topL
  }

}
