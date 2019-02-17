package donnees

trait Interpreter_expression {
    def evalData(data :CaseData):Value = {
          val tmp = data match {
    case Number(n) =>  Number(n)
    case Formule(lt,br,v) => DataInterpreteur.evalData(data )
			case _ => P()
  }
    tmp match {
      case Number(n) => VInt(n)
      case P() => VUncalculable()
    }  
    }

}