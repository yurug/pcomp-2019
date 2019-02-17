package eval

import (
	"container/list"
	"strconv"
)

type FormulasMapping struct {
	formula map[int]*Formula
	unknown map[string]*Unknown
}

// Create a fList structure and fill it
func CreateList(c chan Cell, r chan *FormulasMapping) {
	formulaMap := make(map[int]*Formula)
	unknownMap := make(map[string]*Unknown)
	fl := FormulasMapping{formulaMap, unknownMap}
	fl.fillList(c)
	r <- &fl
}

func (fl *FormulasMapping) GetFormula() map[int]*Formula {
	return fl.formula
}

func (fl *FormulasMapping) GetUnknown() map[string]*Unknown {
	return fl.unknown
}

//	Initialize the fList with cells given through channel c, send a pointer to self to caller through channel r
func (fl *FormulasMapping) fillList(c chan Cell) {
	var formulaList = list.New()
	var unknownList = list.New()
	for f := range c {
		switch f.(type) {
		case *Formula:
			insert(f.(*Formula), formulaList)
		case *Unknown:
			unknownList.PushBack(f.(*Unknown))
		}
	}
	fl.createMaps(formulaList, unknownList)
}

// Insert Formula into a list, preserving formulas order (Start(X,Y))
func insert(f *Formula, l *list.List) {
	for e := l.Front(); e != nil; e = e.Next() {
		if compareCoord(f.Start, e.Value.(*Formula).Start) == -1 {
			continue
		}
		l.InsertBefore(f, e)
		return
	}
	l.PushBack(f)
}

// Create maps of valid formulas and unknown cells from given lists
func (fl *FormulasMapping) createMaps(validList *list.List, invalidList *list.List) {
	var i = 0
	for e := validList.Front(); e != nil; e = e.Next() {
		fl.formula[i] = e.Value.(*Formula)
		i++
	}
	for e := invalidList.Front(); e != nil; e = e.Next() {
		element := e.Value.(*Unknown)
		x := strconv.Itoa(element.Coordinate().X)
		y := strconv.Itoa(element.Coordinate().Y)
		fl.unknown[x+","+y] = e.Value.(*Unknown)
	}
}

// Compare between two coordiantes (first X then Y)
func compareCoord(c1 Coordinate, c2 Coordinate) int {
	if c1.X > c2.X {
		return 1
	}
	if c1.X < c2.X {
		return -1
	}
	if c1.Y > c2.Y {
		return 1
	}
	if c1.Y < c2.Y {
		return -1
	}
	return 0
}
