package eval

import (
	"container/list"
	"strconv"
)

type formList interface {
	createList() *list.List
	insertFormula(f *Formula)
	deleteFormula()
	getList() list.List
	getDepends(c *Coordinate) []Coordinate
}

type fList struct {
	l list.List
}

func (fl *fList) createList() *list.List {
	return list.New()
}

func (fl *fList) getList() list.List {
	return fl.l
}

func (fl *fList) insertFormula(f *Formula) {
	for e := fl.l.Front(); e != nil; e = e.Next() {
		if compareCoord(f.Start, e.Value.(Formula).Start) == -1 {
			continue
		}
		fl.l.InsertBefore(f, e)
	}
}

func (fl *fList) deleteFormula(f *Formula) {
	for e := fl.l.Front(); e != nil; e = e.Next() {
		if compareCoord(f.position, e.Value.(Formula).position) == 0 {
			fl.l.Remove(e)
		}
	}
}

func (fl *fList) getDepends(c Cell) []Coordinate {
	var dep []Coordinate
	var value, _ = strconv.Atoi(c.Value())
	for e := fl.l.Front(); e != nil; e = e.Next() {
		if compareCoord(c.Coordinate(), e.Value.(Formula).Start) == -1 {
			break
		}
		if isIn(c.Coordinate(), e.Value.(Formula)) && (value == e.Value.(Formula).ToEval) {
			dep = append(dep, e.Value.(Formula).position)
		}
	}
	return dep
}

func isIn(c Coordinate, f Formula) bool {
	return compareCoord(c, f.Start) > 1 &&
		compareCoord(c, f.End) < 1
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
