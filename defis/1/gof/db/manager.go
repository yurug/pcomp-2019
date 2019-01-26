package db

import (
	"fmt"
	"os"
)

type Controller struct {
	filename *os.File
}

func NewController(path string) (*Controller, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, fmt.Errorf("error")
	}
	return &Controller{
		filename: file,
	}, nil
}

// return next line from the file
func (ctlr *Controller) GetLine() string {
	return "s"
}

// return line at the index 'ID'
func (ctlr *Controller) GetLineByID(numLine int) string {
	return "s"
}

//
func (ctlr *Controller) GetCell(r int, c int) string {
	return "s"
}

//
func (ctlr *Controller) WriteLine(numLine int, line string) error {
	return nil
}

//
func (ctlr *Controller) WriteCell(r int, c int, v int) error {
	return nil
}
