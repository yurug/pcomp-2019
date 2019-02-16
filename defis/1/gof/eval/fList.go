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

func (fl *fList) create() *list.List {
	return list.New()
}

func (fl *fList) list() list.List {
	return fl.l
}

func (fl *fList) fillList(c chan Formula) {
	for f:= range c {
		fl.insert(f)
	}
}

func (fl *fList) insert(f Formula) {
	for e := fl.l.Front(); e != nil; e = e.Next() {
		if compareCoord(f.Start, e.Value.(Formula).Start) == -1 {
			continue
		}
		fl.l.InsertBefore(f, e)
	}
}

func (fl *fList) delete(f Formula) {
	for e := fl.l.Front(); e != nil; e = e.Next() {
		if compareCoord(f.position, e.Value.(Formula).position) == 0 {
			fl.l.Remove(e)
		}
	}
}

func (fl *fList) dependencies(oldC Cell, newC Cell) []Coordinate {
	var dep []Coordinate
	var oldVal, _ = strconv.Atoi(oldC.Value())
	var newVal, _ = strconv.Atoi(newC.Value())
	for e := fl.l.Front(); e != nil; e = e.Next() {
		if compareCoord(newC.Coordinate(), e.Value.(Formula).Start) == -1 {
			return dep
		}
		if contains(newC.Coordinate(), e.Value.(Formula)) &&
			((oldVal == e.Value.(Formula).ToEval) || (newVal == e.Value.(Formula).ToEval)) {
			dep = append(dep, e.Value.(Formula).position)
		}
	}
	return dep
}

func (fl *fList) createMap() map[int]Formula {
	var m = make(map[int]Formula)
	var i = 0
	for e := fl.l.Front(); e != nil; e = e.Next() {
		m[i] = e.Value.(Formula)
		i++
	}
	return m
}

func contains(c Coordinate, f Formula) bool {
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
