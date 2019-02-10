package parserutil

import (
	"fmt"
	"log"
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
const EXPRESSION_FORMULA = `=#[(]\d+, \d+, \d+, \d+, \d+[)]`
const BINARY_FILE = "binaries/binary"
const DETAILS = "binaries/details"
const FORMULAS_FILE = "binaries/formulas"
const DEPENDENCIES_FILE = "binaries/dependencies"

//ParseSheet takes a file's path and a channel. It extracts all the Cells from the file and send them
//Into the channel to another go-routine. It returns error if the controller fails to init
//Or if NextLine() read all the file
func ParseSheet(sheet string, c chan eval.Formula, chbreak chan int) error {
	defer close(c)
	controller, err := db.New(sheet)
	if err != nil {
		fmt.Printf("%v", err)
		return fmt.Errorf("Error while calling new controller for ParseSheet: %v", err)
	}
	rowID := 0

	binaryFile, _ := db.NewFile(BINARY_FILE)
	detailsFile, _ := db.NewFile(DETAILS)
	formulasFile, _ := db.NewFile(FORMULAS_FILE)

	for {
		line, err := controller.NextLine()
		if err != nil {
			chbreak <- 1
			return err
		}

		values, formulas, lineSize := preprocess(string(line), rowID, c)
		_, err = binaryFile.WriteBytes(values)
		if err != nil {
			chbreak <- 1
			return err
		}

		_, err = detailsFile.WriteLines(strconv.Itoa(rowID) + ":" + strconv.Itoa(lineSize) + "\n")
		if err != nil {
			chbreak <- 1
			return err
		}

		_, err = formulasFile.WriteLines(formulas)
		if err != nil {
			chbreak <- 1
			return err
		}

		rowID++
	}
}

func preprocess(line string, rowID int, c chan eval.Formula) ([]uint8, string, int) {
	cells := strings.Split(string(line[:]), ";")
	number := make([]uint8, len(cells))
	formula := ""
	cmp := 0

	reg, err := regexp.Compile(`[0-9]+`)
	if err != nil {
		log.Fatal(err)
	}

	for column, cell := range cells {
		switch checkType(cell) {
		case KIND_NUMBER:
			v, _ := strconv.ParseUint(cell, 10, 8)
			number[cmp] = uint8(v)
			cmp++
		case KIND_FORMULA:
			formula += strconv.Itoa(rowID) + ";" + strconv.Itoa(column) + ";"
			formula += strings.Join(reg.FindAllString(cell, -1), ",") + "\n"
			number[cmp] = uint8(0)
			cmp++
		default:
			number[cmp] = uint8(0)
			cmp++
		}
	}
	return number, formula, len(cells)
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
		var validFormula = regexp.MustCompile(EXPRESSION_FORMULA)
		if validFormula.MatchString(cell) {
			return KIND_FORMULA
		}
		return KIND_UNKNOWN
	}
	return KIND_NUMBER
}
