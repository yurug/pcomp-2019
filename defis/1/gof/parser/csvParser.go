package parser

import (
	"fmt"
	"regexp"
	"strconv"
	"strings"

	"github.com/yurug/pcomp-2019/defis/1/gof/db"
	"github.com/yurug/pcomp-2019/defis/1/gof/eval"
)

//ParseCsv TO-DO
func ParseSheet(sheet string, c chan eval.Cell) (string, error) {
	controller, err := db.NewController(sheet)
	if err != nil {
		return "", fmt.Errorf("Error while calling new controller for ParseSheet: %v", err)
	}

	rowID := 0
	for err == nil {
		line, err := controller.NextLine()
		if err != nil {
			continue
			// TO CHANGE
		}
		cells := strings.Split(string(line[:]), ";")
		for columnID, cell := range cells {
			ok, err := isNumber(cell)
			if err != nil {
				c <- eval.NewUnknown(rowID, columnID)
				continue
			}
			if ok {
				v, _ := strconv.Atoi(cell)
				number, err := eval.NewNumber(rowID, columnID, v)
				if err != nil {

				}
				c <- number
				continue
			}
			//formula treatment
		}

	}
	return "", nil
}

func isNumber(cell string) (bool, error) {
	_, err := strconv.Atoi(cell)
	if err != nil {
		var validFormula = regexp.MustCompile(`=#[(]\d+, \d+, \d+, \d+, \d+[)]`)
		//tbd
		if validFormula.MatchString(cell) {

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
