package donnees

class GestionnaireDependance(fs:FeuilleSimple) {
  
  def addDependanceToList():Unit={
    for ((id0,(f,l)) <- fs.listFormule)
      for((id1,Case(x,y))<- fs.listCoord)
        if(id0!=id1)
          f match {
            case Formule(Case(r1,c1),Case(r2,c2),v) =>
              if(r1<=x && x<=r2 && c1<=y && y<=c2){
                fs.listFormule + (id0 ->(f,id1::l))
              }
            case _ =>Nil
          }
  }
  
  def MalFormeesNaive():Unit={ 
    for ((k,(f,l)) <- fs.listFormule){
      if(l.contains(P())){
        val Some((data,l))=fs.listFormule.get(k)
        fs.listFormule + (k -> (P(),l))
      }
    }
  }
  
  def remove(num: Int, list: List[Int]) = list diff List(num)
  
  def SuppDependance(id:Int):Unit={
    for ((k,(f,l)) <- fs.listFormule){
      if(l.contains(id)) 
        remove(id,l)
    }
  }
  
  def BienFormees():Int={
    var i=0
     for ((id,(Formule(c1,c2,v),l)) <- fs.listFormule)
       if (l==Nil){
         fs.listFormule + (id -> (DataInterpreteur.getEvalRegionV0(c1,c2,v,fs.getView),l))
         SuppDependance(id)
         i+=1
       }
     i
  }
  
  def MalFormees():Unit={
    while(BienFormees()==0)
      for ((k,(f,l)) <- fs.listFormule)
        f match{
          case Formule(c1,c2,v) => fs.listFormule + (k -> (P(),l))
          case _ => Nil
        }
  }
  
  def getDependance(id:Int):List[Int]={
    val Some((data,l)) = fs.listFormule.get(id)
    l
  }
  
  def setDependance(id:Int, idl:Int): Unit = {
      val l= getDependance(id)
      val data =fs.getCaseData(id)
      fs.listFormule + (id ->(data,idl::l))
  }
}