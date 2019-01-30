package donnees 

class Interpreteur_implement(
    sheet :FeuilleWithDependance){
  
	private val sheet_iterator = sheet.iterator

	
	//il faut aussi géré le cas au il y a pas la possibilité de calcule le nombre de v 
	//donc pour mettre le type P() donc le type de reteur c est option[Int] pour None ou Some
	
	def evalData (data: CaseData): Option[Int] ={
		data match  {
			case Number (n) => Some(n)
			case Formule (lt,br,v) => 
				val dependance_case = sheet.getRegion(lt,br)
				def count_1D_array (array: Array[CaseData]) = 
					array.count( data => 
					if (evalData(data) == v) {true} else {false}
					)
				Some((dependance_case.map (count_1D_array _)).sum)
		}
	}
  

	def evalCase (i:Int, j:Int): Int = evalData (sheet.getData(Case (i,j)))

	def evalSheet : Array[Array[Int]] = {//throw Exception	
			val tmp = sheet.getSize
			val i = tmp._1
			val j = tmp._2
			val sheet_data = sheet.getRegion(Case (0,0),Case (i-1,j-1))
			sheet_data.map (array1D => array1D.map (evalData))
	}

	def eval_next_expr(): Int = evalData (sheet_iterator.next)

}