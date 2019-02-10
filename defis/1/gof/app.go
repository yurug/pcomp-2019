package main

import (
	"fmt"
	"os"

	"github.com/yurug/pcomp-2019/defis/1/gof/db"
)

func main() {
	args := os.Args[1:]
	if len(args) < 4 {
		fmt.Printf("Not enough arguments\n")
		return
	}
	//	csv := args[0]
	user := args[1]
	view := args[2]

	//changes := args[3]
	/*
		ch := make(chan eval.Formula)
		chbreak := make(chan int)
		defer close(chbreak)
		go parserutil.ParseSheet(csv, ch, chbreak)
		<-chbreak
	*/

	f, _ := db.NewFileModifier(view, user)
	g, _ := f.GetValue(3, 1)
	fmt.Println(g)

	f.WriteValue(10, 10, 10)
	g, _ = f.GetValue(10, 10)

	fmt.Println(g)
}
