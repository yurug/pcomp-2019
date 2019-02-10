package donnees

abstract class FileCSV_DAO[T <: Any](fileName:String, separator:String) 
extends CSVFile(fileName, separator) with Iterator[T]{
  private var next_elt :List[T] = Nil
  
  private def load_next = {	
    val data = this.nextData
    if (data == null) {this.close()}     
    val tmp = parser(data)
    if (tmp != null) { next_elt	= tmp::Nil}
    else {next_elt	= Nil}
  }
  
  def init = this.load_next 
  
  def parser (data: Array[String]):T
  
  
  def next () : T= {
    val tmp = next_elt
    load_next
    tmp.head
  }
  def hasNext = if (next_elt != Nil) {true} else {false}

}

