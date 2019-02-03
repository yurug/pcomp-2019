package main

import (
	"fmt"
	"os"

	"github.com/yurug/pcomp-2019/defis/1/gof/eval"
	"github.com/yurug/pcomp-2019/defis/1/gof/parseutil"
)

func main() {
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
