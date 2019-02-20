package db

import (
	"container/list"
	"fmt"
	"math/rand"
	"os"
	"strconv"
)

const THREAD_NUM = 4
const DEPENDENCY_REPO = "dependencies/"

type threadChan []chan CellLine

var (
	instance threadChan
)

func ThreadChannelsGetInstance() threadChan {
	if instance == nil {
		instance = make(threadChan, THREAD_NUM)
		for i := 0; i < THREAD_NUM; i++ {
			instance[i] = make(chan CellLine)
		}
	}

	return instance
}

type CellLine struct {
	LineFormulas []string
	LineNum      int
}

func WriteLineOnDisk(c chan CellLine) {
	for line := range c {
		f, err := os.Create(DEPENDENCY_REPO + strconv.Itoa(line.LineNum))
		if err != nil {
			fmt.Println(DEPENDENCY_REPO + strconv.Itoa(line.LineNum))
		}
		//		fIndex, err = os.Create(DEPENDENCY_REPO + strconv.Itoa(c.Line) + ".index")
		for i := range line.LineFormulas {
			f.WriteString(strconv.Itoa(i) + ":" + line.LineFormulas[i])
		}
	}
}

func LineDistribution(globalSize int, c chan CellLine) {
	for i := 0; i < globalSize; i++ {
		go WriteLineOnDisk(ThreadChannelsGetInstance()[i])
	}
	for line := range c {
		ThreadChannelsGetInstance()[rand.Intn(THREAD_NUM-1)] <- line
	}
	for _, c := range ThreadChannelsGetInstance() {
		close(c)
	}

}

type FormulaChannel struct {
	id *list.Element
}

func CreateCellDependencies(fd *FileDescriptor) {
	chanCe := make(chan CellLine)
	go LineDistribution(THREAD_NUM, chanCe)
	o := 0

	c := make(chan int, 50000)

	formulasList := fd.formulasMapping.ListID()

	for e := formulasList.Front(); e != nil; e = e.Next() {
		fmt.Println(fd.formulasMapping.Formula(e.Value.(int)))
	}

	for lineId := 0; lineId < len(fd.lineSize); lineId++ {
		lineSize := fd.lineSize[lineId]
		fmt.Println(strconv.Itoa(o) + "lignes")
		var cl CellLine
		cl.LineNum = lineId
		cl.LineFormulas = make([]string, lineSize/2)

		for j := 0; j < lineSize/2; j++ {
			go TraiteOneCell(&cl.LineFormulas[j], j, lineId, fd, formulasList, c)
			c <- 1
		}
		o++
		chanCe <- cl
	}
	close(chanCe)
}

func TraiteOneCell(memory *string, x int, y int, fd *FileDescriptor, formulasList *list.List, c chan int) {
	var formulaToRemove []*list.Element
	var formulaString string = "\n"

	for e := formulasList.Front(); e != nil; e = e.Next() {
		formula := fd.formulasMapping.Formula(e.Value.(int))
		if formula.StartAfter(x, y) {
			break
		} else {

			if formula.Contain(x, y) {
				formulaString = strconv.Itoa(e.Value.(int)) + "," + formulaString

				if formula.DecrementArea() < 0 {
					formulaToRemove = append(formulaToRemove, e)
				}
			}
		}

		for _, element := range formulaToRemove {
			formulasList.Remove(element)
		}
	}
	memory = &formulaString
	_ = <-c
}
