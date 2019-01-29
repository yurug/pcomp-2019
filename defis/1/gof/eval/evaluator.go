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
