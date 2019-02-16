package main

import (
	"fmt"
	"os"

	parserutil "github.com/yurug/pcomp-2019/defis/1/gof/parseutil"

	"github.com/yurug/pcomp-2019/defis/1/gof/db"
	"github.com/yurug/pcomp-2019/defis/1/gof/eval"
)

func main() {
	args := os.Args[1:]
	if len(args) < 4 {
		fmt.Printf("Not enough arguments\n")
		return
	}
	formulaMaps := make(map[int]eval.Formula)
	csv := args[0]
	formulaCh := make(chan eval.Formula)
	doneParse := make(chan int)
	defer close(doneParse)

	go parserutil.FormulasList(formulaCh, formulaMaps, doneParse)
	go parserutil.ParseSheet(csv, formulaCh)

	<-doneParse
	/*
		for k, v := range formulaMaps {
			fmt.Printf("key[%s] value[%s]\n", k, v)
		}
	*/
	fmt.Println(len(formulaMaps))
	f, _ := db.NewFileModifier(parserutil.BINARY_FILE, parserutil.DETAILS)
	g, _ := f.GetValue(10, 10)
	fmt.Printf("Value Read before Write: %v\n", g)

	f.WriteValue(10, 10, 98, 0)
	g, _ = f.GetValue(10, 10)

	fmt.Printf("Value Read after Write: %v\n", g)
}
