
=> liste tt les formule dans une list et au meme temps copie les valeur entier dans view0 
=> apres a la place des formules on fait comme un index des couple ou un truc comme ca qui fait referance a un list des formules



def addFormuleToList(f1:CaseData,id:Int):Unit={
    for ((k,(f2,l)) <- listFormule){
      (f1,f2) match{
        case (Formule(Case(r1,c1),Case(r2,c2),_),
            Formule(Case(r01,c01),Case(r02,c02),_))
        => {
          /*cas ou f1 < f2 => f1 inclus dans f2 */ 
          if(r1>=r01 && c1>=c01 && r2<=r02 && c2<=c02) id::l 
          /*cas ou f2 < f1 => f2 inclus dans f1*/
          else if(r1<=r01 && c1<=c01 && r2>=r02 && c2>=c02){
            listFormule.get(id) match{
              case Some((data,ll)) => listFormule + (id ->(data,k::ll))
              case _ => Nil
            }
          }
          /*cas ou f1 < f2 && f2 < f1 => une partie de f1 dans f2 
           * (donc mal formées les deux) 
           * */
          else if(!(c2<=c01 || c02<=c1 || r2<=r01 || r02<=r1))
            listFormule + (k ->(P(),l))
          else 
            Nil
          }  
        case (_,_)=>Nil
      }
    }
  }



  def recMalFormeesP(id:List[Int],dep:List[Int]){
    
     dep match{
       case h::t => 
         dep.map (idi => {
            val Some((data,l))=listFormule.get(idi)
            for(i <- l)
              if(id.contains(i)){
                listFormule + (idi -> (P(),l))
              }
         })
      }
                    else recMalFormeesP(h::id,t) 
       case Nil => Nil             
     }
  }



  package donnees 

class Interpreteur_implement{
  
  /*
	private val sheet_iterator = sheet.iterator

	/* if evaluation succes, return a int, else return None */
	def evalData (data: CaseData): Option[Int] ={
		data match  {
			case Number (n) => Some(n)
			case Formule (lt,br,v) => 
				val dependance_case = sheet.getRegion(lt,br)
				def count_1D_array (array: Array[Option[CaseData]]) = 
					array.count( data => evalData(data) match {
						case None => false
						case Some (data) => if (data == v) {true} else {false}							
					}					
					)
				Some((dependance_case.map (count_1D_array _)).sum)
			case _ => None
		}
	}
  

	def evalCase (i:Int, j:Int): Option[Int] = sheet.getData(Case (i,j)) match {
				case None => None
				case Some (data) => evalData (data)	
				}

	def evalSheet : Array[Array[Option[Int]]] = {//throw Exception	
			val dim = sheet.getSize
			val i = dim._1
			val j = dim._2
			val sheet_data = sheet.getRegion(Case (0,0),Case (i-1,j-1))
			sheet_data.map (array1D => array1D.map ( elt => elt match {
				case None => None
				case Some (data) => evalData (data)	
				}
			))
	}
				
	
	def evalData (data: Option[CaseData]): Option[Int] = data match {
				case None => None
				case Some (data) => evalData (data)	
				}
	
	def eval_next_expr() = evalData (sheet_iterator.next)
	
	
	def getDependance(c:Case):List[Case] = {
    def depend_by (case_target: Case ,formule :Formule) = formule match { 
      case Formule(lt,br,v) =>
      if (case_target.i <= lt.i && case_target.i >= br.i 
          && case_target.j >= lt.j && case_target.j <= br.j)
      {true}
      else {false}
    }
    all_formule.filter(depend_by(c,_))
  }
	
	*/

}