package donnees

trait Interpreteur{
	def evalData(data: CaseData) : Option[Int]
	def evalCase (i:Int, j:Int): Option[Int]
	def evalSheet():  Array[Array[Int]]
	def eval_next_expr(): Option[Int]
}