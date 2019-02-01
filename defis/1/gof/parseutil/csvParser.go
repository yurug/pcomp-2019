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

func ParseSheet(sheet string, c chan eval.Cell) error {
	defer close(c)
	controller, err := db.NewController(sheet)
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
		for columnID, cell := range cells {
			switch checkType(cell) {
			case KIND_NUMBER:
				v, _ := strconv.Atoi(cell)
				number, _ := eval.NewNumber(rowID, columnID, v)
				c <- number
			case KIND_FORMULA:
				values := regexp.MustCompile(`\d+`).FindAllString(cell, -1)
				if len(values) != SIZE_FORMULA {
					c <- eval.NewUnknown(rowID, columnID)
					continue
				}
				valuesInt := make([]int, SIZE_FORMULA)
				for i, v := range values {
					valuesInt[i], _ = strconv.Atoi(v)
					//No error because of the regex
				}
				c <- eval.NewFormula(valuesInt[0], valuesInt[1], valuesInt[2], valuesInt[3], valuesInt[4], rowID, columnID)
			case KIND_UNKNOWN:
				c <- eval.NewUnknown(rowID, columnID)
			}
		}

	}
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
