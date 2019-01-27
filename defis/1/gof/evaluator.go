package main

import "fmt"

const KIND_FORMULA = "formula"
const KIND_INTEGER = "integer"

type Formula struct {
	kind   string
	values []int
	input  []int //r1,c1,r2,c2,v
}

func NewFormula(kind string, input []int, values ...int) (*Formula, error) {
	if kind != KIND_FORMULA && kind != KIND_INTEGER {
		return nil, fmt.Errorf("Kind of formula not known")
	}
	/*
		if len(values) == 0 {
			return &Formula{
				kind:   kind,
				values: nil,
				input:  input,
			}, nil
		}
	*/
	return &Formula{
		kind:   kind,
		values: values,
		input:  input,
	}, nil
}

func (f *Formula) Add(val int) {
	f.values = append(f.values, val)
}

func Eval(f Formula) int {
	if len(f.values) == 0 {
		return 0
	}
	return countOccurence(f.input[4], f.values)
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
