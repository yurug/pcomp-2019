trait Interpreteur{
	def evalData(data: CaseData) : Int
	def evalCase (i:Int, j;Int): Int = evalData(sheet.getCell(i,j))
	def evalSheet(): Array[Int]
}