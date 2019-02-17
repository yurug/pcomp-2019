package parserutil

import (
	"fmt"
	"log"
	"regexp"
	"strconv"
	"strings"

	"github.com/yurug/pcomp-2019/defis/1/gof/consts"
	"github.com/yurug/pcomp-2019/defis/1/gof/db"
	"github.com/yurug/pcomp-2019/defis/1/gof/eval"
)

//ParseSheet takes a file's path and a channel. It extracts all the Cells from the file and send them
//Into the channel to another go-routine. It returns error if the controller fails to init
//Or if NextLine() read all the file
func ParseSheet(sheet string, fileD *db.FileDescriptor, chbreak chan int) error {
	fmt.Println("ParseSheet..")
	controller, err := db.NewController(sheet, consts.OPEN_FILE)
	if err != nil {
		return fmt.Errorf("Error while calling new controller for ParseSheet: %v", err)
	}

	rowID := 0

	binaryFile, err := db.NewController(consts.BINARY_FILE, consts.CREATE_FILE)
	if err != nil {
		return err
	}
	detailsFile, err := db.NewController(consts.DETAILS, consts.CREATE_FILE)
	if err != nil {
		return err
	}
	formulasFile, err := db.NewController(consts.FORMULAS_FILE, consts.CREATE_FILE)
	if err != nil {
		return err
	}

	formulasChan := make(chan eval.Cell)
	resultChan := make(chan *eval.FormulasMapping)

	go eval.CreateList(formulasChan, resultChan)

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
	k := <-resultChan
	fileD.DefineFormulasMapping(k)
	fileD.CreateFileCursor(consts.BINARY_FILE, consts.DETAILS)
	chbreak <- 1
	return nil
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
		case consts.KIND_NUMBER:
			v, _ := strconv.ParseUint(cell, 10, 8)
			number[cmp] = byte(v)
			number[cmp+1] = byte(0)
			cmp += 2
		case consts.KIND_FORMULA:
			values := regexp.MustCompile(`\d+`).FindAllString(cell, -1)
			if len(values) != consts.SIZE_FORMULA {
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
		var validFormula = regexp.MustCompile(consts.EXPRESSION_FORMULA)
		if validFormula.MatchString(cell) {
			return consts.KIND_FORMULA
		}
		return consts.KIND_UNKNOWN
	}
	return consts.KIND_NUMBER
}
