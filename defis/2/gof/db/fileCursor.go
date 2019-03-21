package db

import (
	"bufio"
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
		xSize, _ := strconv.Atoi(values[1])

		m[y] = previousX
		previousX += xSize
	}
	fm := FileModifier{f, m}
	return &fm, nil
}

func (fm *FileModifier) GetValue(x int, y int) ([]int, error) {
	fm.file.Seek(int64(fm.m[y]+(x*2)), 0)
	b := make([]byte, 2)
	fm.file.Read(b)

	value := make([]int, 2)
	value[0] = int(b[0])
	value[1] = int(b[1])

	return value, nil
}

func (fm *FileModifier) WriteValue(x int, y int, value int, flag int) {
	fm.file.Seek(int64(fm.m[y]+(x*2)), 0)
	b := make([]byte, 2)
	b[0] = byte(value)
	b[1] = byte(flag)
	fm.file.Write(b)
}
