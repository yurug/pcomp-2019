package parserutil

import (
	"fmt"
	"log"
	"regexp"
	"strconv"
	"strings"

	"github.com/yurug/pcomp-2019/defis/2/gof/db"
	"github.com/yurug/pcomp-2019/defis/2/gof/eval"
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
const CREATE_FILE = 1
const OPEN_FILE = 0
const SPLIT_CAR = ";"

//ParseSheet takes a file's path and a channel. It extracts all the Cells from the file and send them
//Into the channel to another go-routine. It returns error if the controller fails to init
//Or if NextLine() read all the file
func ParseSheet(sheet string, c chan []eval.Cell, chbreak chan int) error {
	fmt.Println("ParseSheet..")
	defer close(c)
	controller, err := db.NewController(sheet, OPEN_FILE)
	if err != nil {
		fmt.Printf("%v", err)
		return fmt.Errorf("Error while calling new controller for ParseSheet: %v", err)
	}
	rowID := 0

	binaryFile, _ := db.NewController(BINARY_FILE, CREATE_FILE)
	detailsFile, _ := db.NewController(DETAILS, CREATE_FILE)
	formulasFile, _ := db.NewController(FORMULAS_FILE, CREATE_FILE)

	for {
		line, err := controller.NextLine()
		if err != nil {
			chbreak <- 1
			return err
		}

		cells := strings.Split(string(line[:]), SPLIT_CAR)
		c <- constructLine(cells, rowID)

		values, formulas, lineSize := preprocess(string(line), rowID)
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

func extractFormulas(formulas *db.Controller) ([]*eval.Formula, error) {
	l := make([]*eval.Formula, 0)
	fml, err := formulas.ReadAll()
	if err != nil {
		return nil, err
	}

	for _, line := range strings.Split(string(fml), "\n") {
		arr := strings.Split(line, ";")
		posArr, err := atoiSlice(arr[:1])
		if err != nil {
			return nil, err
		}
		arr2 := strings.Split(arr[2], ",")
		paramArr, err := atoiSlice(arr2)
		if err != nil {
			return nil, err
		}
		l = append(l, eval.NewFormula(paramArr[0], paramArr[1], paramArr[2], paramArr[3], paramArr[4], posArr[0], posArr[1]))
	}
	return l, nil
}

func preprocess(line string, rowID int) ([]byte, string, int) {
	cells := strings.Split(string(line[:]), SPLIT_CAR)
	number := make([]byte, len(cells)*2)
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
			number[cmp] = byte(v)
			number[cmp+1] = byte(0)
			cmp += 2
		case KIND_FORMULA:
			formula += strconv.Itoa(rowID) + ";" + strconv.Itoa(column) + ";"
			formula += strings.Join(reg.FindAllString(cell, -1), ",") + "\n"
			number[cmp] = byte(0)
			number[cmp+1] = byte(0)
			cmp += 2
		default:
			number[cmp] = byte(0)
			number[cmp+1] = byte(0)
			cmp += 2
		}
	}
	return number, formula, len(number)
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
