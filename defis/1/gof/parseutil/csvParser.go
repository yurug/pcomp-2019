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

func ParseSheet(sheet string, c chan eval.Cell) error {
	defer close(c)
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
