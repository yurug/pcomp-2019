object DataParser{
  
  private def parseData(data : String) = 
    try {
      Number (data.toInt)
    } catch {
      case NumberFormatException => 
      	val tmp = data.split("(")(1).split(")")(0)
      	val int_data = tmp.split(",").map (toInt)
      	val case1 = Case (int_data(0),int_data(1))
      	val case2 = Case (int_data(2),int_data(3))
      	val value = int_data(4)      	
      	Formule (case1,case2,value)
    }	
}