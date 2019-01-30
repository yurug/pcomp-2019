package donnees
import java.io.File

import java.io.PrintWriter
import evaluateur._

object DataParser{
  
  
  def isAllDigits(x: String) = x forall Character.isDigit
  
  def parseData(data : String):CaseData={ 
    val dateREGX = "\\=\\#\\((\\d+),(\\d+),(\\d+),(\\d+),(\\d+)\\)".r    	
    isAllDigits (data) match {  
      case true => Number (data.toInt)
      case false => 
        data match{
          case dateREGX(r1,r2,c1,c2,v)=> println("REGX");
            Formule (Case(r1.toInt,c1.toInt),Case(r2.toInt,c2.toInt),v.toInt)
          case _ => println("P");P()
        }
    }
  }
  
  def formuleToString(cellules: Array[Array[Cellule]]):Unit={
    var i=0; var j=0
    for(l <- cellules){
      for(c <- l){
        //la il faut appele la fonction evalData de la classe Interpreteur_implement 
        //mais il y a un args de FeuilleWithDependance???
       // cellules(i)(j)=new Cellule(evalData(c.getVal));
        c.getVal match {
        case Number(n) => cellules(i)(j)=new Cellule(new Number(n))
        case P() => cellules(i)(j)=new Cellule(P())
      }
        j+=1
     }
      i+=1;j=0
    }
  }
  
   
   def writeView0(cellules: Array[Array[Cellule]]):Unit ={
     val writer = new PrintWriter(new File("view0.csv"))
     for(l <- cellules){
         for(c <- l){
              writer.write(c.getVal+";")
         }
          writer.write("\n")
      }
   
    writer.close()
   }
}