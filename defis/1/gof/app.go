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
	csv := args[0]
	formulaCh := make(chan eval.Formula)
	doneParse := make(chan int)
	var fileDescriptor db.FileDescriptor
	defer close(doneParse)

	go parserutil.ParseSheet(csv, fileDescriptor, doneParse)

	<-doneParse

	f, _ := db.NewFileModifier(parserutil.BINARY_FILE, parserutil.DETAILS)
	g, _ := f.GetValue(10, 10)
	fmt.Printf("Value Read before Write: %v\n", g)

	f.WriteValue(10, 10, 98, 0)
	g, _ = f.GetValue(10, 10)

	fmt.Printf("Value Read after Write: %v\n", g)
}
