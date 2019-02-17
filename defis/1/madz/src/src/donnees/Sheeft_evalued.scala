package donnees

class Sheet_evalued(data0:String,view0:String) 
extends FeuilleSimple(data0,view0) 
with Interpreter_expression {
  /*
   * mock
   */
  def getValueData(c : Case): Option[Value] = {
    c match {
      case Case(0,1) => Some(VInt(1))
    }
  }
  
  /*
   * for this value, give the new value of formule of given case 
   */
  def update_formule(formule:Case, value:Value): Value  =
    getValueData(formule) match{
    case Some(v)  => {
      val VInt(i) = v
      if (v == value) {              
      VInt(i+1)
      }
      else {VInt(i-1)        
      }

    }
    
      
  }
    
}