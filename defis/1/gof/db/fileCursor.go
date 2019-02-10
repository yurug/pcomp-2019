package db

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

type FileModifier struct {
	file *os.File
	m    map[int]int
}

func NewFileModifier(path string, desc string) (*FileModifier, error) {
	f, error := os.OpenFile(path, os.O_RDWR, 0755)
	if error != nil {
		return nil, error
	}

	detailsFile, error := os.Open(desc)
	if error != nil {
		return nil, error
	}

	r := bufio.NewReader(detailsFile)
	m := make(map[int]int)
	previousX := 0
	for {
		line, _, err := r.ReadLine()
		if err != nil {
			break
		}
		values := strings.Split(string(line), ":")
		y, _ := strconv.Atoi(values[0])
		x, _ := strconv.Atoi(values[1])

		m[y] = previousX
		previousX += x
	}
	fm := FileModifier{f, m}
	return &fm, nil
}

func (fm *FileModifier) GetValue(x int, y int) (int, error) {
	fm.file.Seek(int64(fm.m[y]+x), 0)
	b := make([]byte, 1)
	fm.file.Read(b)

	return int(b[0]), nil
}

func (fm *FileModifier) WriteValue(x int, y int, value int) {
	fm.file.Seek(int64(fm.m[y]+x), 0)
	b := make([]byte, 1)
	b[0] = byte(uint8(value))
	_, err := fm.file.Write(b)
	if err != nil {
		fmt.Println("ici")
	}
}
