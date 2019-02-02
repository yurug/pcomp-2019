package parserutil

import (
	"fmt"
	"regexp"
	"strconv"
	"strings"

	"github.com/yurug/pcomp-2019/defis/1/gof/db"
	"github.com/yurug/pcomp-2019/defis/1/gof/eval"
)

const KIND_NUMBER = "NUMBER"
const KIND_FORMULA = "FORMULA"
const KIND_UNKNOWN = "UNKOWN"
const SIZE_FORMULA = 5

//ParseSheet takes a file's path and a channel. It extracts all the Cells from the file and send them
//Into the channel to another go-routine. It returns error if the controller fails to init
//Or if NextLine() read all the file
func ParseSheet(sheet string, c chan []eval.Cell) error {
	defer close(c)
	controller, err := db.New(sheet)
	if err != nil {
		return fmt.Errorf("Error while calling new controller for ParseSheet: %v", err)
	}

	rowID := 0
	for {
		line, err := controller.NextLine()
		if err != nil {
			return err
		}
		cells := strings.Split(string(line[:]), ";")
		c <- constructLine(cells, rowID)
		rowID++

	}
}

func constructLine(cells []string, rowID int) []eval.Cell {
	formatedCells := make([]eval.Cell, len(cells))

	for columnID, cell := range cells {
		switch checkType(cell) {
		case KIND_NUMBER:
			v, _ := strconv.Atoi(cell)
			number, _ := eval.NewNumber(rowID, columnID, v)
			formatedCells[columnID] = number
		case KIND_FORMULA:
			values := regexp.MustCompile(`\d+`).FindAllString(cell, -1)
			if len(values) != SIZE_FORMULA {
				formatedCells[columnID] = eval.NewUnknown(rowID, columnID)
				continue
			}
			valuesInt, _ := atoiSlice(values)
			formatedCells[columnID] = eval.NewFormula(valuesInt[0], valuesInt[1], valuesInt[2], valuesInt[3], valuesInt[4], rowID, columnID)
		case KIND_UNKNOWN:
			formatedCells[columnID] = eval.NewUnknown(rowID, columnID)
		}
	}
	return formatedCells
}

func atoiSlice(arr []string) ([]int, error) {
	results := make([]int, len(arr))
	var err error
	for i, v := range arr {
		results[i], err = strconv.Atoi(v)
		if err != nil {
			return nil, fmt.Errorf("error occured in atoiSlice: %v", err)
		}
	}
	return results, nil
}

func checkType(cell string) string {
	_, err := strconv.Atoi(cell)
	if err != nil {
		var validFormula = regexp.MustCompile(`=#[(]\d+, \d+, \d+, \d+, \d+[)]`)
		if validFormula.MatchString(cell) {
			return KIND_FORMULA
		}
		return KIND_UNKNOWN
	}
	return KIND_NUMBER
}
