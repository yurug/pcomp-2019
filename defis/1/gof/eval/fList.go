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

type FList struct {
	l list.List
}

func (fl *FList) createList() *list.List {
	return list.New()
}

func (fl *FList) getList() list.List {
	return fl.l
}

func (fl *FList) insertFormula(f *Formula) {
	for e := fl.l.Front(); e != nil; e = e.Next() {
		if compareCoord(f.Start, e.Value.(Formula).Start) == -1 {
			continue
		}
		fl.l.InsertBefore(f, e)
	}
}

func (fl *FList) deleteFormula(f *Formula) {
	for e := fl.l.Front(); e != nil; e = e.Next() {
		if compareCoord(f.position, e.Value.(Formula).position) == 0 {
			fl.l.Remove(e)
		}
	}
}

func (fl *FList) getDepends(oldC Cell, newC Cell) []Coordinate {
	var dep []Coordinate
	var oldVal, _ = strconv.Atoi(oldC.Value())
	var newVal, _ = strconv.Atoi(newC.Value())
	for e := fl.l.Front(); e != nil; e = e.Next() {
		if compareCoord(newC.Coordinate(), e.Value.(Formula).Start) == -1 {
			return dep
		}
		// FIX ME
		if isIn(newC.Coordinate(), e.Value.(Formula)) &&
			((oldVal == e.Value.(Formula).ToEval) || (newVal == e.Value.(Formula).ToEval)) {
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
