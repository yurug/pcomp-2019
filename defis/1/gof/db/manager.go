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

//ReadAll call ioutil.ReadAll on the file
func (c *Controller) ReadAll() ([]byte, error) {
	return ioutil.ReadAll(c.file)
}

//NextLine returns the next line read in the associated file, or an error if EOF
func (c *Controller) NextLine() ([]byte, error) {
	ok := c.scanner.Scan()
	if !ok {
		return nil, fmt.Errorf("Error in GetLine() of %s", c.file.Name())
	}
	return c.scanner.Bytes(), nil
}

//LineByID returns the line at position n
//Need to discuss about it
func (c *Controller) LineByID(numLine int) string {
	return "s"
}
