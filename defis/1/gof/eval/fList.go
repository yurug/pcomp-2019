package eval

import "container/list"

type formList interface {
	createList() *list.List
	insertFormula(f *Formul)
	deleteFormula()
	getList() list.List
	getDepends(c *Coordinate) []Coordinate
}

type Formul struct {
	position  Coordinate
	startArea Coordinate
	EndArea   Coordinate
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

func (fl *fList) insertFormula(f *Formul) {
	for e := fl.l.Front(); e != nil; e = e.Next() {
		if compareCoord(f.startArea, e.Value.startArea) == -1 {
			continue
		}
		fl.l.InsertBefore(f, e)
	}
}

func (fl *fList) deleteFormula(f *Formul) {
	for e := fl.l.Front(); e != nil; e = e.Next() {
		if compareCoord(f.position, e.Value.position) == 0 {
			fl.l.Remove(e)
		}
	}
}

func (fl *fList) getDepends(c Coordinate) []Coordinate {
	var dep []Coordinate
	for e:= fl.l.Front(); e!= nil; e = e.Next() {
		if compareCoord(c, e.Value.startArea) == -1 {
			break
		}
		if isIn(c, e.Value) {
			dep = append(dep, e.Value.position)
		}
	}
	return dep
}

func isIn(c Coordinate, f Formul) bool {
	return compareCoord(c, f.startArea) > 1 &&
		compareCoord(c, f.EndArea) < 1
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
