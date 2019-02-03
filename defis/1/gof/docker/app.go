package main

import (
	"fmt"
	"os"

	"./eval"
	parserutil "./parseutil"
)

//"./ws data.csv user.txt view0.csv changes.txt"
func main() {
	fmt.Println("Hello moto")
	args := os.Args[1:]
	if len(args) < 4 {
		fmt.Printf("Not enough arguments\n")
		return
	}
	csv := args[0]
	//user := args[1]
	view := args[2]
	//changes := args[3]
	ch := make(chan []eval.Cell)
	e, err := eval.NewEvaluator(view)
	if err != nil {
		fmt.Printf("Error with evaluator: %v\n", err)
	}
	go parserutil.ParseSheet(csv, ch)
	e.Process(ch)
}

func test(ch chan []eval.Cell) {
	for line := range ch {
		for _, v := range line {
			switch cell := v.(type) {
			default:
				fmt.Printf("unexpected type %T", cell)
			case *eval.Number:
				fmt.Printf("Cell of type Number and value: %v\n", cell.Value())
			case *eval.Unknown:
				fmt.Printf("Cell of type Unknown and value: %v\n", cell.Value())
			case *eval.Formula:
				fmt.Printf("Cell of type Formula: %v / %v / %v\n", cell.Start, cell.End, cell.ToEval)
			}
		}
	}
}
