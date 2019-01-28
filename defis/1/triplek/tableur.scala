abstract class Cell (private var num:Int ,private var letters:String ) {}

class CellInt (private var entier:Int ,private var num:Int ,private var letters:String ) extends Cell(num,letters){}

class CellFormule (private var num:Int, private var letters:String, private var r1:Int, private var r2:Int, private var c1:Int, private var c2:Int, private var v:Int) extends Cell(num,letters) {}

class ErrorCell (private var num:Int ,private var letters:String) extends Cell(num, letters) {}

class Operation (private var cel: Cell ) {}
