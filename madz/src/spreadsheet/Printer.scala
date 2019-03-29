package spreadsheet

import request.Change

/*
 * printer data into string according to format specified in specification 
 */
object Printer {
  def toString_value (v: Value) = v match {
    case VInt( i) => i.toString()
    case VUncalculable ()=> "P"
    }
    def toString (c: Case) = c match {
      case Case(i,j) => i + " " +j    
      }
      
      def toString (op : Change) : String= { op match {
        case Change(lt,br,v) => 
          (Printer.toString(lt ) 
            + " "  + Printer.toString(br) 
            + " " + toString_value(v)
          )
          
        }
        
      }
    }