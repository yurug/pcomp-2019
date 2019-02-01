package eval

func Eval(f Formula) int {
	/*
		if len(f.values) == 0 {
			return 0
		}
		return countOccurence(f.input[4], f.values)
	*/
	return 0
}

func countOccurence(n int, values []int) int {
	count := 0
	for _, v := range values {
		if n == v {
			count++
		}
	}
	return count
}

//on suppose qu'on a tt les cellules chargées en mémoires
//fonction fait par l'utilisateur pour modifier une cellule par un int
func userPutValue(val int, x int, y int, values [][]Cell)(error){
	number, err := NewNumber(x,y,val)
	if(err != nil){
		return err
	}
	values[x][y] = number
	return err
}

//fonction fait par l'utilisateur pour modifier une cellule par une formule
func userPutFormul(r1 int, c1 int, r2 int, c2 int, v int,
	x int, y int, values [][]Cell){
	formula := NewFormula(r1,c1,r2,c2,v,x,y)
	values[x][y] = formula

}