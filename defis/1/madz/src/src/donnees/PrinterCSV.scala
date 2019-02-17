package donnees

object PrinterCSV {
  def toString_value (v: Value) = v match {
    case VInt( i) => i.toString()
    case VUncalculable ()=> "P"
  }
    def toString (c: Case) = c match {
    case Case(i,j) => i + " " +j    
  }
    
    def toString (op : Change) : String= { op match {
      case Change(c,v) => 
        (PrinterCSV.toString(c ) 
        + " " + toString_value(v)
         )
        
    }
      
    }
}