package main

import (
	"fmt"
	"os"

	parserutil "github.com/yurug/pcomp-2019/defis/2/gof/parseutil"

	"github.com/yurug/pcomp-2019/defis/2/gof/db"
	"github.com/yurug/pcomp-2019/defis/2/gof/eval"
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
	e, _ := eval.NewEvaluator("view0.csv")
	go e.Process(ch, doneEval)
	<-doneParse
	<-doneEval

	f, _ := db.NewFileModifier(parserutil.BINARY_FILE, parserutil.DETAILS)
	g, _ := f.GetValue(10, 10)
	fmt.Printf("Value Read before Write: %v\n", g)

	f.WriteValue(10, 10, 98, 0)
	g, _ = f.GetValue(10, 10)

	fmt.Printf("Value Read after Write: %v\n", g)
}
