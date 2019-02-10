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
	ch := make(chan eval.Formula)
	chbreak := make(chan int)
	defer close(chbreak)
	go parserutil.ParseSheet(csv, ch, chbreak)
	<-chbreak

	f, _ := db.NewFileModifier("binary", "details")
	g, _ := f.GetValue(10, 10)
	fmt.Printf("Value Read before Write: %v\n", g)

	f.WriteValue(10, 10, 99)
	g, _ = f.GetValue(10, 10)

	fmt.Printf("Value Read after Write: %v\n", g)
}
