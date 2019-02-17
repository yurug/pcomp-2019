package db

import (
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

func ThreadChannelsGetInstant() threadChan {
	if instance == nil {
		instance = make(threadChan, THREAD_NUM)
	}

	return instance
}

type CellLine struct {
	Line         []byte
	LineFormulas []string
	LineNum      int
}

func WriteLineOnDisk(c chan CellLine) {
	for line := range c {
		f, _ := os.Create(DEPENDENCY_REPO + strconv.Itoa(line.LineNum))
		//		fIndex, err = os.Create(DEPENDENCY_REPO + strconv.Itoa(c.Line) + ".index")
		for i := range line.Line {
			f.WriteString(strconv.Itoa(i) + ":" + line.LineFormulas[i])
		}
	}
}

func LineDistribution(globalSize int, c chan CellLine) {
	for line := range c {
		ThreadChannelsGetInstant()[rand.Intn(THREAD_NUM-1)] <- line
	}
}
