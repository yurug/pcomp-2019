package util

import java.io._

/*
 * CSV file reader
 */
class CSVFile(fileName:String, separator:String) extends BufferedReader(new FileReader(fileName)){
	
  /*
   * return next line of CSV file
   */
	final def nextData : Array[String] = { 
	  var tmp:String = null
		try{
		  tmp = this.readLine()     
		}catch{
			case ex: IOException =>  null
			}
		if (tmp == null) { null} //if end of file
			else {tmp.split(separator)}
		}
		
	}


