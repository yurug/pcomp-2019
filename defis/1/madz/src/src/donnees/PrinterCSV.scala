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
      case Change(lt,br,v) => 
        (PrinterCSV.toString(lt ) 
        + " "  + PrinterCSV.toString(br) 
        + " " + toString_value(v)
         )
        
    }
      
    }
}