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
	reader  *bufio.Reader
}

//New singleton concept as we want only one controller over the database
func NewController(path string, flag int) (*Controller, error) {
	var err error
	var f *os.File
	if flag == 0 {
		f, err = os.Open(path)
	} else {
		f, err = os.Create(path)
	}
	if err != nil {
		return nil, err
	}
	return &Controller{
		file:    f,
		scanner: bufio.NewScanner(f),
		reader:  bufio.NewReader(f),
	}, nil
}

//ReadAll call ioutil.ReadAll on the file
func (c *Controller) ReadAll() ([]byte, error) {
	return ioutil.ReadAll(c.file)
}

//NextLine returns the next line read in the associated file, or an error if EOF
func (c *Controller) NextLine() ([]byte, error) {
	token, _, err := c.reader.ReadLine()
	if err != nil {
		return nil, fmt.Errorf("Error in GetLine() of %s: %v", c.file.Name(), err)
	}
	return token, nil
}

//LineByID returns the line at position n
//Need to discuss about it
func (c *Controller) LineByID(numLine int) string {
	return "s"
}

func (c *Controller) WriteBytes(values []uint8) (int, error) {
	return c.file.Write(values)
}

func (c *Controller) WriteLines(values string) (int, error) {
	return c.file.WriteString(values)
}
