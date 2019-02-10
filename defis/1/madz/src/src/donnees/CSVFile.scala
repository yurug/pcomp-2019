package donnees

import java.io._
class CSVFile(fileName:String, separator:String) extends BufferedReader(new FileReader(fileName)){
	

	def nextData : Array[String] = { 
	  var tmp:String = null
		try{
		  tmp = this.readLine()     
		}catch{
			case ex: IOException =>  null
			}
		if (tmp == null) { null}
			else {tmp.split(separator)}
		}
		
	}

/*
*/
