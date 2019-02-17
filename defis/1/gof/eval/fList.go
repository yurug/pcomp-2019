package eval

import (
	"container/list"
	"strconv"
)

/*FormulasMapping is a struct to store formulas and unknown cells
**formula[key] has an integer as key to iterate through it easily
**unknown[key] has a string as key representing [x,y]
 */
type FormulasMapping struct {
	formula map[int]*Formula
	unknown map[string]*Unknown
}

//CreateList takes as input 2 channelsm create a FormulasMap struct
//fill it with the cells received in c, then send it to r
func CreateList(c chan Cell, r chan *FormulasMapping) {
	fl := newFormulasMapping()
	fl.fillList(c)
	r <- fl
}

func newFormulasMapping() *FormulasMapping {
	return &FormulasMapping{formula: make(map[int]*Formula), unknown: make(map[string]*Unknown)}
}

func (fl *FormulasMapping) ListID() *list.List {
	l := list.New()
	for k := range fl.formula {
		l.PushFront(k)
	}
	return l
}

//Formula returns the formula with id as key
func (fl *FormulasMapping) Formula(id int) *Formula {
	return fl.formula[id]
}

//Unknown returns the unknown with id as key
func (fl *FormulasMapping) Unknown(id string) *Unknown {
	return fl.unknown[id]
}

//Initialize the fList with cells given through channel c,
//send a pointer to self to caller through channel r
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

// Compare between two coordiantes (first X then Y) return 1 if c1 is GT, -1 if c1 is LT
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
