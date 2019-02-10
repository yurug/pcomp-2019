package parserutil

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/yurug/pcomp-2019/defis/1/gof/db"
	"github.com/yurug/pcomp-2019/defis/1/gof/eval"
)

type UserCommands struct {
	value eval.Number
}

//ParseUserRequest TO-DO
func ParseUserRequest(usrReq string) ([]UserCommands, error) {
	controller, err := db.NewController(usrReq, 0)
	if err != nil {
		return nil, fmt.Errorf("Error while calling new controller for ParseSheet: %v", err)
	}

	var results []UserCommands

	for {
		line, err := controller.NextLine()
		if err != nil {
			break
		}
		cells := strings.Split(string(line[:]), " ")
		if len(cells) == 3 {
			cellsInt := make([]int, 3)
			for i, cell := range cells {
				cellsInt[i], _ = strconv.Atoi(cell)
			}
			var number, _ = eval.NewNumber(cellsInt[0], cellsInt[1], cellsInt[2])
			results = append(results, UserCommands{value: *number})
		}
	}
	return results, nil
}
