package db

import (
	"bufio"
	"os"
	"strconv"
	"strings"

	"github.com/yurug/pcomp-2019/defis/1/gof/eval"
)

type FileDescriptor struct {
	file       *os.File
	coord      map[int]int
	formulas   map[int]eval.Formula
	unknown    map[string]eval.Unknown
	lineNumber int
}

func NewFileDescriptor() (*FileDescriptor, error) {
	coord := make(map[int]int)
	formulas := make(map[int]eval.Formula)
	unknown := make(map[string]eval.Unknown)
	lineNumber := 0
	fd := FileDescriptor{nil, coord, formulas, unknown, lineNumber}
	return &fd, nil
}

func (fd *FileDescriptor) CreateFileCursor(path string, desc string) error {
	f, error := os.OpenFile(path, os.O_RDWR, 0755)
	if error != nil {
		return error
	}

	detailsFile, error := os.Open(desc)
	if error != nil {
		return error
	}

	fd.file = f

	r := bufio.NewReader(detailsFile)
	previousX := 0
	for {
		line, _, err := r.ReadLine()
		if err != nil {
			break
		}
		values := strings.Split(string(line), ":")
		y, _ := strconv.Atoi(values[0])
		xSize, _ := strconv.Atoi(values[1])

		fd.coord[y] = previousX
		previousX += xSize
		fd.lineNumber++
	}
	return nil
}

func (fd *FileDescriptor) GetValue(x int, y int) ([]int, error) {
	_, err := fd.file.Seek(int64(fd.coord[y]+(x*2)), 0)
	if err != nil {
		return nil, err
	}

	b := make([]byte, 2)
	_, err = fd.file.Read(b)
	if err != nil {
		return nil, err
	}

	value := make([]int, 2)
	value[0] = int(b[0])
	value[1] = int(b[1])

	return value, nil
}

func (fd *FileDescriptor) WriteValue(x int, y int, value int, flag int) (int, error) {
	_, err := fd.file.Seek(int64(fd.coord[y]+(x*2)), 0)
	if err != nil {
		return 0, err
	}

	b := make([]byte, 2)
	b[0] = byte(value)
	b[1] = byte(flag)

	n, err := fd.file.Write(b)
	if err != nil {
		return 0, err
	}
	return n, nil
}

func (fd *FileDescriptor) DefineFormulaMap(m map[int]eval.Formula) {
	fd.formulas = m
}

func (fd *FileDescriptor) DefineUnknownMap(m map[string]eval.Unknown) {
	fd.unknown = m
}
