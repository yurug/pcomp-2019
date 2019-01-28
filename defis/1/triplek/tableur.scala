abstract class Cell (private var num:int ,private var letters:String ) {

  
}



class CellInt (private var entier:int ,private var num:int ,private var letters:String ) extends cells(num,letters){

  
}


class CellFormule (private var r1:int,private var r2:int, private var c1:int,  private var c2:int,private var v:int,private var num:int ,private var letters:String ) extends  cells(num,letters) {


  
}

class ErroCell
{


}

class Operation (private var cel:cells ) {




}