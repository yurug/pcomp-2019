package eval

import (
	"container/list"
)

type fList struct {
	validF   map[int]Formula
	invalidF map[int]Unknown
}

// Create a fList structure and fill it
func (fl *fList) create(c chan Cell, r chan *fList) {
	fl.validF = make(map[int]Formula)
	fl.invalidF = make(map[int]Unknown)
	fl.fillList(c, r)
}

//	Initialize the fList with cells given through channel c, send a pointer to self to caller through channel r
func (fl *fList) fillList(c chan Cell, r chan *fList) {
	var validFlist = list.New()
	var invalidFlist = list.New()
	for f := range c {
		switch f.(type) {
		case *Formula:
			insert(f.(*Formula), validFlist)
		case *Unknown:
			invalidFlist.PushBack(f)
		}
	}
	fl.createMaps(validFlist, invalidFlist)
	r <- fl
	close(r)
}

// Insert Formula into a list, preserving formulas order (Start(X,Y))
func insert(f *Formula, l *list.List) {
	for e := l.Front(); e!= nil; e = e.Next() {
		if compareCoord(f.Start, e.Value.(Formula).Start) == -1{
			l.InsertBefore(f, e)
			return
		}
	}
	l.PushBack(f)
}

// Create maps of valid formulas and unknown cells from given lists
func (fl *fList) createMaps(validL *list.List, invalidL *list.List) {
	var i = 0
	for e := validL.Front(); e != nil; e = e.Next() {
		fl.validF[i] = e.Value.(Formula)
		i++
	}
	i = 0
	for e := invalidL.Front(); e != nil; e = e.Next() {
		fl.invalidF[i] = e.Value.(Unknown)
		i++
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
