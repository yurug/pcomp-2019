package donnees 

class Interpreteur_implement(
    sheet :FeuilleWithDependance){
  
	private val sheet_iterator = sheet.iterator

	/* if evaluation succes, return a int, else return None */
	def evalData (data: CaseData): Option[Int] ={
		data match  {
			case Number (n) => Some(n)
			case Formule (lt,br,v) => 
				val dependance_case = sheet.getRegion(lt,br)
				def count_1D_array (array: Array[Option[CaseData]]) = 
					array.count( data => evalData(data) match {
						case None => false
						case Some (data) => if (data == v) {true} else {false}							
					}					
					)
				Some((dependance_case.map (count_1D_array _)).sum)
			case _ => None
		}
	}
  

	def evalCase (i:Int, j:Int): Option[Int] = sheet.getData(Case (i,j)) match {
				case None => None
				case Some (data) => evalData (data)	
				}

	def evalSheet : Array[Array[Option[Int]]] = {//throw Exception	
			val dim = sheet.getSize
			val i = dim._1
			val j = dim._2
			val sheet_data = sheet.getRegion(Case (0,0),Case (i-1,j-1))
			sheet_data.map (array1D => array1D.map ( elt => elt match {
				case None => None
				case Some (data) => evalData (data)	
				}
			))
	}
				
	
	def evalData (data: Option[CaseData]): Option[Int] = data match {
				case None => None
				case Some (data) => evalData (data)	
				}
	
	def eval_next_expr() = evalData (sheet_iterator.next)
	
	

}