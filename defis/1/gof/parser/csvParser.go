package parser

import (
	"fmt"
	"regexp"
	"strconv"

	"github.com/yurug/pcomp-2019/defis/1/gof/db"
	"github.com/yurug/pcomp-2019/defis/1/gof/eval"
)

//ParseCsv TO-DO
func ParseSheet(sheet string, c chan eval.Cell) (string, error) {
	controller, err := db.NewController(sheet)
	if err != nil {
		return "", fmt.Errorf("Error while calling new controller for ParseSheet: %v", err)
	}

	err = nil
	for err == nil {
		line, err := controller.NextLine()

		c <- eval.NewNumber(5, 5, 5)

	}
	/*
		controller, err := db.NewController(csv)
		if err != nil {
			return ""
			}
	*/
	return "", nil
}

func isNumber(cell []byte) (bool, error) {
	cellString := string(cell[:])
	cellInt, err := strconv.Atoi(cellString)
	if err != nil {
		var validFormula = regexp.MustCompile(`=#[(]\d+, \d+, \d+, \d+, \d+[)]`)
		//tbd
		if validFormula.Match(cell) {

			return true, nil
		}
		//case formula
		return true, nil
	}
	return true, nil
}

/*
func StringToLine(input string) {

}

func LineToString() string {

	return ""
}

func CellToValue() {

}

func ValueToCell() {

}
*/
