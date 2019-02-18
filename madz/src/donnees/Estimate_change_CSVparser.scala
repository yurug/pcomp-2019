package donnees

trait Estimate_change_CSVparser {
  def parser (data: Array[String]) = data match{
			  case null => null
			  case _ => if (data.length == 3){
			    new Estimate_change(
				Case(Integer.parseInt(data(0)),Integer.parseInt(data(1))),
				DataParser.parseData(data(2))
			)
			  } else { 
			    //new java.util.zip.DataFormatException().printStackTrace()
			    null}
			    
			  
			    
			}
}