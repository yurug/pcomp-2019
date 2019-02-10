package donnees

trait Request_parser {
  def parser (data: Array[String]) = data match{
			  case null => null
			  case _ => if (data.length == 3){
			    new Estimate_change(
				Case(Integer.parseInt(data(0)),Integer.parseInt(data(1))),
				DataParser.parseData(data(2))
			)
			  } else {throw new java.util.zip.DataFormatException()}
			    
			  
			    
			}
}