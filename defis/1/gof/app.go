package main

import (
	"fmt"
	"os"

	"github.com/yurug/pcomp-2019/defis/1/gof/parseutil"

	"github.com/yurug/pcomp-2019/defis/1/gof/db"
	"github.com/yurug/pcomp-2019/defis/1/gof/eval"
)

func main() {
	args := os.Args[1:]
	if len(args) < 4 {
		fmt.Printf("Not enough arguments\n")
		return
	}
	csv := args[0]
	ch := make(chan []eval.Cell)
	doneParse := make(chan int)
	doneEval := make(chan int)
	defer close(doneParse)
	go parserutil.ParseSheet(csv, ch, doneParse)
	e, err := eval.NewEvaluator(args[2])
	if err != nil {
		fmt.Println(err)
	}

	go e.Process(ch, doneEval)
	<-doneParse
	<-doneEval

	f, err := db.NewFileModifier(parserutil.BINARY_FILE, parserutil.DETAILS)
	if err != nil {
		fmt.Println(err)
	}
	g, err := f.GetValue(10, 10)
	if err != nil {
		fmt.Println(err)
	}
	fmt.Printf("Value Read before Write: %v\n", g)

	f.WriteValue(10, 10, 98, 0)
	g, err = f.GetValue(10, 10)
	if err != nil {
		fmt.Println(err)
	}

	fmt.Printf("Value Read after Write: %v\n", g)
}
