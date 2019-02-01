package db

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"os"
)

const LINE_DELIMITER = '\n'

// Controller is a struct used to access the database and the file associated to it
type Controller struct {
	file    *os.File
	scanner *bufio.Scanner
}

//NewController takes into input a path to the file and returns a *Controller
func NewController(path string) (*Controller, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, fmt.Errorf("error")
	}
	return &Controller{
		file:    f,
		scanner: bufio.NewScanner(f),
	}, nil
}

func (c *Controller) ReadAll() ([]byte, error) {
	return ioutil.ReadAll(c.file)
}

//GetLine returns the next line read in the associated file, or an error if EOF
func (c *Controller) NextLine() ([]byte, error) {
	ok := c.scanner.Scan()
	if !ok {
		return nil, fmt.Errorf("Error in GetLine() of %s", c.file.Name())
	}
	return c.scanner.Bytes(), nil
	/*
		rd := bufio.NewReader(c.file)
		line, err := rd.ReadBytes(LINE_DELIMITER)
		if err != nil {
			return nil, fmt.Errorf("Error in GetLine() of %s : %v", c.file.Name(), err)
		}
		return line, err
	*/
}

//GetLineByID returns the line at position n
//Need to discuss about it
func (c *Controller) LineByID(numLine int) string {
	return "s"
}

/*
//GetCell returns the cell in the file associated to the (row, column) tuple in arguments
func (c *Controller) NextCell(row int, column int) ([]byte, error) {
	rd := bufio.NewReader(c.file)
	for i := 0; i < row; i++ {
		_, err := rd.ReadBytes('\n')
		if err != nil {
			return nil, fmt.Errorf("Error in GetCell(%v, %v) of %s : %v", row, column, c.file.Name(), err)
		}
	}

	line, err := rd.ReadBytes('\n')
	if err != nil {
		return nil, fmt.Errorf("Error in GetCell(%v, %v) of %s : %v", row, column, c.file.Name(), err)
	}
	slice := strings.Split(line, ";")
	return slice[column], nil
}

//WriteLine return an error if it fails to write the string into the file
//Need to discuss about it, maybe not needed into Controller
func (c *Controller) WriteLine(numLine int, line string) error {
	wr := bufio.NewWriter(c.file)
	_, err := wr.WriteString(line)
	if err != nil {
		return fmt.Errorf("Error in WriteLine of [%s] into %s: %v", line, c.file.Name(), err)
	}
	return nil
}

//WriteCell works like WriteLine
//Need to discuss about it, maybe not needed into Controller
func (c *Controller) WriteCell(row int, column int, v int) error {
	return nil
}
*/
