package main

import (
	"fmt"
	"os"

	"github.com/yurug/pcomp-2019/defis/1/gof/eval"
	"github.com/yurug/pcomp-2019/defis/1/gof/parseutil"
)

func main() {
	filename := os.Args[1]
	ch := make(chan eval.Cell)
	go parserutil.ParseSheet(filename, ch)
	for v := range ch {
		switch cell := v.(type) {
		default:
			fmt.Printf("unexpected type %T", cell)
		case *eval.Number:
			fmt.Printf("Cell of type Number and value: %v\n", cell.Value)
		case *eval.Unknown:
			fmt.Printf("Cell of type Unknown and value: %v\n", cell.Value())
		case *eval.Formula:
			fmt.Printf("Cell of type Formula: %v / %v / %v\n", cell.Start, cell.End, cell.ToEval)
		}
	}
}
