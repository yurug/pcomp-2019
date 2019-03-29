package spreadsheet

abstract class FileCSV_DAO[T <: Any](fileName:String, separator:String) 
extends CSVFile(fileName, separator) with Iterator[T]{
  private var next_elt :List[T] = Nil
  
  /* precondition: input CSV file is open
   * postcondition: 
   * return next object T contain in CSV file
   * if end of file, close the CSV file
   */
  private final def load_next = {	
    try{
    val data = this.nextData
    if (data == null) {this.close()}     
    val tmp = parser(data)
    if (tmp != null) { next_elt	= tmp::Nil}
    else {next_elt	= Nil}      
    }catch{
      case e => e.printStackTrace()
    }

  }
  
  /*
   * precondition: exist CSV file 
   */
  final def init = {
    try{
    this.load_next  
    }catch{
      case e => e.printStackTrace()
    }
     
  }
  
  protected def parser (data: Array[String]):T
  
  
  final def next () : T= {
    val tmp = next_elt
    load_next
    tmp.head
  }
  final def hasNext = if (next_elt != Nil) {true} else {false}

}

