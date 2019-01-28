package donnees 
class Interpreteur_implement(
	private var sheet :FeuilleWithDependance){
	//private val sheet_iterator = sheet.iterator
/*
	override def evalData (data: CaseData): Int =
		data match  {
			case Number (n) => n
			case Formule (lt,br,v) => 
				val dependance_case = sheet.getRegion(lt,br)
				dependance_case.count( data => 
					if (evalData(data) = v) {true} else {false}
				)
		}
  }
		

	override def evalCase (i:Int, j:Int): Int = evalData (sheet.getCell(i,j))

	override def evalSheet(): Array[Array[Int]] =		
		val (i,j) = sheet.getSize
		val sheet_data = sheet.getRegion(Case (0,0),Case (i-1,j-1))
		sheet_data.map (evalData)

	override def eval_next_expr(): Int = evalData (sheet_iterator.next)
*/
}