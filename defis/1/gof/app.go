package main

import (
	"fmt"
	"os"
	"runtime"

	parserutil "github.com/yurug/pcomp-2019/defis/1/gof/parseutil"

	"github.com/yurug/pcomp-2019/defis/1/gof/db"
)

func main() {
	args := os.Args[1:]
	if len(args) < 4 {
		fmt.Printf("Not enough arguments\n")
		return
	}
	csv := args[0]
	doneParse := make(chan int)

	var fileDescriptor *db.FileDescriptor
	fileDescriptor, err := db.NewFileDescriptor()
	if err != nil {
		fmt.Println(err)
		return
	}

	defer close(doneParse)

	go parserutil.ParseSheet(csv, fileDescriptor, doneParse)

	<-doneParse

	runtime.GC()
	PrintMemUsage()

	db.CreateCellDependencies(fileDescriptor)

	runtime.GC()
	PrintMemUsage()
	/*
		g, _ := fileDescriptor.GetValue(1, 1)
		fmt.Printf("Value Read before Write: %v\n", g)

		fileDescriptor.WriteValue(10, 10, 98, 0)
		g, _ = fileDescriptor.GetValue(10, 10)

		fmt.Printf("Value Read after Write: %v\n", g) */
}

func PrintMemUsage() {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	// For info on each, see: https://golang.org/pkg/runtime/#MemStats
	fmt.Printf("Alloc = %v MiB", bToMb(m.Alloc))
	fmt.Printf("\tTotalAlloc = %v MiB", bToMb(m.TotalAlloc))
	fmt.Printf("\tSys = %v MiB", bToMb(m.Sys))
	fmt.Printf("\tNumGC = %v\n", m.NumGC)
}

func bToMb(b uint64) uint64 {
	return b / 1024 / 1024
}
