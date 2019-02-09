package db

import (
	"os"
)

type FileManager struct {
	file *os.File
}

func NewFile(path string) (*FileManager, error) {
	f, error := os.Create(path)
	if error != nil {
		return nil, error
	}

	fm := FileManager{f}
	return &fm, nil
}

func (fm *FileManager) WriteBytes(values []uint8) (int, error) {
	return fm.file.Write(values)
}

func (fm *FileManager) WriteLines(values string) (int, error) {
	return fm.file.WriteString(values)
}
