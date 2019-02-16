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
const CREATE_FILE = 1
const OPEN_FILE = 0

//ParseSheet takes a file's path and a channel. It extracts all the Cells from the file and send them
//Into the channel to another go-routine. It returns error if the controller fails to init
//Or if NextLine() read all the file
func ParseSheet(sheet string, fileD *db.FileDescriptor, chbreak chan int) error {
	fmt.Println("ParseSheet..")
	controller, err := db.NewController(sheet, OPEN_FILE)
	if err != nil {
		return fmt.Errorf("Error while calling new controller for ParseSheet: %v", err)
	}

	rowID := 0

	binaryFile, err := db.NewController(BINARY_FILE, CREATE_FILE)
	if err != nil {
		return err
	}
	detailsFile, err := db.NewController(DETAILS, CREATE_FILE)
	if err != nil {
		return err
	}
	formulasFile, err := db.NewController(FORMULAS_FILE, CREATE_FILE)
	if err != nil {
		return err
	}

	fileD, err = db.NewFileDescriptor()
	if err != nil {
		return err
	}

	formulasChan := make(chan eval.Cell)
	resultChan := make(chan eval.FList)

	for {
		line, err := controller.NextLine()
		if err != nil {
			break
		}

		values, formulas, lineSize := preprocess(string(line), rowID, formulasChan)
		_, err = binaryFile.WriteBytes(values)
		if err != nil {
			return err
		}

		_, err = detailsFile.WriteLines(strconv.Itoa(rowID) + ":" + strconv.Itoa(lineSize) + "\n")
		if err != nil {
			return err
		}

		_, err = formulasFile.WriteLines(formulas)
		if err != nil {
			return err
		}
		rowID++
	}
	close(formulasChan)
	resultList := <-resultChan
	fileD.DefineFormulaMap()
	fileD.DefineUnknownMap()
	chbreak <- 1
	return nil
}

func FormulasList(c chan eval.Formula, mapping map[int]eval.Formula, chbreak chan int) {
	i := 0
	for element := range c {
		mapping[i] = element
		i++
	}
	chbreak <- 1
}

func dependencies(formulas *db.Controller) error {
	/*	var err error
		dep, _ := db.NewController(DEPENDENCIES_FILE, CREATE_FILE)
		for {
			line, err := formulas.NextLine()
			if err != nil {
				break
			}
			lineStr := string(line[:])
			tmpArr := strings.Split(lineStr, ";")
			pos := strings.Split(tmpArr[2], ",")
			x, y := pos[0], pos[1]
		}
		return err*/
	return nil
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

func preprocess(line string, rowID int, c chan eval.Cell) ([]byte, string, int) {
	var formula eval.Cell
	cells := strings.Split(string(line[:]), ";")
	number := make([]byte, len(cells)*2)
	formulas := ""
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
			values := regexp.MustCompile(`\d+`).FindAllString(cell, -1)
			if len(values) != SIZE_FORMULA {
				formula = eval.NewUnknown(rowID, column)
			} else {
				valuesInt, _ := atoiSlice(values)
				formula = eval.NewFormula(valuesInt[0], valuesInt[1], valuesInt[2], valuesInt[3], valuesInt[4], rowID, column)
				formulas += strconv.Itoa(rowID) + ";" + strconv.Itoa(column) + ";"
				formulas += strings.Join(reg.FindAllString(cell, -1), ",") + "\n"
			}
			c <- formula
			number[cmp] = byte(0)
			number[cmp+1] = byte(0)
			cmp += 2
		default:
			formula = eval.NewUnknown(rowID, column)
			c <- formula
			number[cmp] = byte(0)
			number[cmp+1] = byte(0)
			cmp += 2
		}
	}
	return number, formulas, len(number)
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
