package spreadsheet

class Formule_graph {
  protected var listFormule = scala.collection.mutable.Map[Int,(Formule_node,List[Int])]()
  protected var listCoord:Map[Int,(Case)] = Map()
  protected var listValue=scala.collection.mutable.Map[Int,Value]()
  def listCoord_size = listCoord.size
  def add_formule(f:Formule,numligne: Int ,numcol: Int) = {
    var node = new Formule_node()
    node.set_expression(f)
    node.set_position(Case(numligne,numcol))
    listFormule += (listCoord.size -> (node,Nil))
    listCoord += (listCoord.size -> Case (numligne,numcol) )
  }
  
  def isFormule(c:String):Boolean = {
    println(c+" "+c.toInt)
    return listCoord.contains(c.toInt)
  }  
  def all_node = listFormule.toList.map(
      e => {
        val _,(_,(node,_)) = e
        node
      }
      )
  
  protected def addDep(id:Int,l:List[Int]):Unit={
    val Some((data,l0)) = listFormule.get(id)
    listFormule(id) = (data,l)
  }
  protected def idToCase (id:Int)  = listCoord.get(id) match{
    case None => Nil
    case Some(c) => List(c)
    }
    
    protected def SuppDependance(id:Int):Unit={
      for ((k,(f,l)) <- listFormule)
        if(l.contains(id)) 
          remove(id,l,k)
      }
      
      protected def get_FormuleId(c: Case) = {
        val res = listCoord.find( 
          (K ) => { val _,d = K
            if (d == c) {true} else {false}         
          })
        res match{
          case None => None
          case Some((id, _)) => Some(id) 
          }
        }  
        
        protected def setDependance(id:Int, idl:Int): Unit = {
          val l= getDependance(id)
          val data = getCaseData(id)
          val (content,_),_ = listFormule(id)
          content.set_expression(data)
          listFormule(id) = (content,idl::l) 
        }    
        def getCaseData(id:Int):Formule={
          val Some((data,l)) = listFormule.get(id)
          data.get_expression
        }

        def getCaseData(c:Case):Formule ={  
          val Some(id) = get_FormuleId(c)
          val Some((data,l)) = listFormule.get(id)
          data.get_expression
        }
        
        protected def getCase(id:Int):Case={
          val Some(c) = listCoord.get(id)
          c
        }
        protected def setCaseData(id:Int,data:Formule):Unit={
          val Some((data0,l0)) = listFormule.get(id)
          data0.set_expression(data)
          
        }
        
        /*
         * delete formule num from dependance of formule id
         */
        protected def remove(num:Int, l:List[Int],id:Int):Unit={
          var ll=List[Int]()
          for(i <- l){
            if(i!=num)
              ll=i::ll
          }
          addDep(id,ll)
        }
        
        protected def getDependance(id:Int):List[Int]={
          val Some((data,l)) = listFormule.get(id)
          l
        }
         def getDependance(c:Case):List[Case] = {
          get_FormuleId(c) match {
            case None => Nil //case c is a int
              case Some(id) => { 
                val Some((data,dependances)) = listFormule.get(id)        
                val listCase = dependances.map(id => listCoord.get(id))
                val listClean = listCase.filter(elt => elt match {case None => false case Some(_) => true })
                listClean.map(a => a match {case Some(a) => a})
              }
            }
          }  

}