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
      println(id0+"=>"+ll)
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
  
  def BienFormees():Int={
    var i=0
    println("i="+i)
    println(fs.listFormule)
     for ((id,(Formule(c1,c2,v),l)) <- fs.listFormule)
       if (l==Nil){
         if(c2.i-c1.i<1000){
           fs.setCaseData(id,DataInterpreteur.getEvalRegionV0(c1,c2,v,fs.getView))
         }else{
           fs.fileRegion(id)
           fs.setCaseData(id,DataInterpreteur.getEvalRegionV1(id,v))
         }
         SuppDependance(id)
         i+=1
       }else println(l)
      println("fin=>"+i)
     i
  }
  
  def MalFormees():Unit={
    while(BienFormees()!=0){
      println("MalFormees")
      for ((k,(f,l)) <- fs.listFormule)
        f match{
          case Formule(c1,c2,v) => 
            println("id=>"+k)
            fs.setCaseData(k,P())
          case _ => Nil
        }
    }
  }
  
  def getDependance(id:Int):List[Int]={
    val Some((data,l)) = fs.listFormule.get(id)
    l
  }
  
  def setDependance(id:Int, idl:Int): Unit = {
      val l= getDependance(id)
      val data =fs.getCaseData(id)
      fs.listFormule(id) = (data,idl::l) 

  }
}