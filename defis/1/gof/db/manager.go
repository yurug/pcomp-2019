package db

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

// Controller is a struct used to access the database and the file associated to it
type Controller struct {
	file *os.File
}

//NewController takes into input a path to the file and returns a *Controller
func NewController(path string) (*Controller, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, fmt.Errorf("error")
	}
	return &Controller{
		file: f,
	}, nil
}

//GetLine returns the next line read in the associated file, or an error if EOF
func (ctlr *Controller) GetLine() (string, error) {
	rd := bufio.NewReader(ctlr.file)
	line, err := rd.ReadString('\n')
	if err != nil {
		return "", fmt.Errorf("Error in GetLine() of %s : %v", ctlr.file.Name(), err)
	}
	return line, err
}

//GetLineByID returns the line at position n
//Need to discuss about it
func (ctlr *Controller) GetLineByID(numLine int) string {
	return "s"
}

//GetCell returns the cell in the file associated to the (row, coloumn) tuple in arguments
func (ctlr *Controller) GetCell(r int, c int) (string, error) {
	rd := bufio.NewReader(ctlr.file)
	for i := 0; i < r; i++ {
		_, err := rd.ReadString('\n')
		if err != nil {
			return "", fmt.Errorf("Error in GetCell(%v, %v) of %s : %v", r, c, ctlr.file.Name(), err)
		}
	}

	line, err := rd.ReadString('\n')
	if err != nil {
		return "", fmt.Errorf("Error in GetCell(%v, %v) of %s : %v", r, c, ctlr.file.Name(), err)
	}
	slice := strings.Split(line, ";")
	return slice[c], nil
}

//WriteLine return an error if it fails to write the string into the file
//Need to discuss about it, maybe not needed into Controller
func (ctlr *Controller) WriteLine(numLine int, line string) error {
	wr := bufio.NewWriter(ctlr.file)
	_, err := wr.WriteString(line)
	if err != nil {
		return fmt.Errorf("Error in WriteLine of [%s] into %s: %v", line, ctlr.file.Name(), err)
	}
	return nil
}

//WriteCell works like WriteLine
//Need to discuss about it, maybe not needed into Controller
func (ctlr *Controller) WriteCell(r int, c int, v int) error {
	return nil
}
