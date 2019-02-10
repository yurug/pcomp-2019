package donnees

abstract class FileCSV_DAO[T <: Any](fileName:String, separator:String) 
extends CSVFile(fileName, separator) with Iterator[T]{
  private var next_elt :List[T] = Nil
  
  private def load_next = {	next_elt	= parser(this.nextData)::Nil}
  
  def init = this.load_next 
  
  def parser (data: Array[String]):T
  
  
  def next () : T= {
    val tmp = next_elt
    load_next
    if (next_elt == null) {this.close()} 
    tmp.head
  }
  def hasNext = if (next_elt != null) {true} else {false}

}

