package donnees

class GestionnaireDependance(fs:FeuilleSimple) {
  
  def addDependanceToList():Unit={
    for ((id0,(f,l)) <- fs.listFormule){
      var ll=List[Int]()
      for((id1,Case(x,y))<- fs.listCoord)
        if(id0!=id1){
          f match {
            case Formule(Case(r1,c1),Case(r2,c2),v) =>
              if(r1<=x && x<=r2 && c1<=y && y<=c2){
                ll=id1::ll
              }
            case _ =>Nil
          }
      }
      fs.addDep(id0,ll)
    }
  }
  
  def MalFormeesNaive():Unit={ 
    for ((k,(f,l)) <- fs.listFormule){
      if(l.contains(P())){
        val Some((data,l))=fs.listFormule.get(k)
        fs.setCaseData(k,P())
      }
    }
  }
  
  def remove(num:Int, l:List[Int],id:Int):Unit={
    var ll=List[Int]()
    for(i <- l){
      if(i!=num)
        ll=i::ll
    }
    fs.addDep(id,ll)
  }
  
  def SuppDependance(id:Int):Unit={
    for ((k,(f,l)) <- fs.listFormule)
      if(l.contains(id)) 
        remove(id,l,k)
  }
  
  def BienFormees():Unit={
    var i=0
     for ((id,(Formule(c1,c2,v),l)) <- fs.listFormule)
       if (l==Nil){
         fs.setCaseData(id,DataInterpreteur.getEvalRegionV0(c1,c2,v,fs.getView))
         SuppDependance(id)
         i+=1
       }
     if(i!=0) BienFormees()
  }
  
  def MalFormees():Unit={
      for ((k,(f,l)) <- fs.listFormule)
        f match{
          case Formule(c1,c2,v) => 
            fs.setCaseData(k,P())
          case _ => Nil
        }
  }
  
  def getDependance(id:Int):List[Int]={
    val Some((data,l)) = fs.listFormule.get(id)
    l
  }
  def getDependance(formule:Case):List[Case]={
    fs.get_FormuleId(formule) match{
      case None => Nil
      case Some(id) => getDependance(id).map( 
          id => { val Some(c) = fs.listCoord.get(id)
        c
      })
    }
  }
  
  def setDependance(id:Int, idl:Int): Unit = {
      val l= getDependance(id)
      val data =fs.getCaseData(id)
      fs.listFormule(id) = (data,idl::l) 

  }
}