class Interpreteur_implement(
	private var sheet :FeuilleWithDependance){

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