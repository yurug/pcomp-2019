package donnees

trait Interpreteur{
	def evalData(data: CaseData) : Int
	def evalCase (i:Int, j:Int): Int
	def evalSheet():  Array[Array[Int]]
	def eval_next_expr(): Int
}