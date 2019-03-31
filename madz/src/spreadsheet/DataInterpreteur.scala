package spreadsheet

import java.io.File

import java.io.PrintWriter

/*
 * count nomber occurence of 1 int in a region of data file
 */
object DataInterpreteur {
  
  def getEvalRegionV0(c1:Case, c2:Case,v:Int,view0:String):Value={
    var count=0
    var i=0;var j=0
    for(l <- io.Source.fromFile(view0).getLines){
      if(c1.i<=i && i<=c2.i)
        for(c <- l.split(";")){
          if(c1.j<=j && j<=c2.j)
            if (c.equals(v+"")) count+=1
          j+=1
        }
      i+=1;j=0
    }
    VInt(count)
  }
  
  def getEvalRegionV1(id:Int,v:Int):CaseData={
    var count=0
    for(l <- io.Source.fromFile(id+"").getLines){
       val lignelist =l.split(" ")
       count+=lignelist.filter(_ == v).size
    }
    Number(count)
  }
  

    

}