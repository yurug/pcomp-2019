
package donnees 
class Interpreteur_implement(
	private var sheet :FeuilleWithDependance){
	//private val sheet_iterator = sheet.iterator

	override def evalData (data: CaseData): Int =
		data match  {
			case Number (n) => n
			case Formule (lt,br,v) => 
				val dependance_case = sheet.getRegion(lt,br)
				def count_1D_array (array: Array[CaseData]) = 
					array.count( data => 
					if (evalData(data) == v) {true} else {false}
					)
				(dependance_case.map (count_1D_array _)).sum
		}
  }
		

	override def evalCase (i:Int, j:Int): Int = evalData (sheet.getData(Case (i,j)))

	override def evalSheet : Array[Array[Int]] = {//throw Exception	
			val tmp = sheet.getSize
			val i = tmp._1
			val j = tmp._2
			val sheet_data = sheet.getRegion(Case (0,0),Case (i-1,j-1))
			sheet_data.map (array1D => array1D.map (evalData))
		}

	override def eval_next_expr(): Int = evalData (sheet_iterator.next)

}