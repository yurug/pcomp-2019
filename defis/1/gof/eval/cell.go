package eval

import (
	"fmt"
	"strconv"

	"github.com/yurug/pcomp-2019/defis/1/gof/consts"
)

type Cell interface {
	Coordinate() Coordinate
	Value() string
	Visited() bool
	MarkVisit()
}

type Coordinate struct {
	X, Y int
}

type Number struct {
	position Coordinate
	value    int
	visited  bool
}

func NewNumber(x int, y int, v int) (*Number, error) {
	if v < 0 || v > 255 {
		return nil, fmt.Errorf("Invalid value for Number type : Must have 0 <= v <= 255")
	}
	return &Number{
		position: Coordinate{x, y},
		value:    v,
		visited:  false,
	}, nil
}

func (n *Number) Coordinate() Coordinate {
	return n.position
}

func (n *Number) Value() string {
	return strconv.Itoa(n.value)
}

func (n *Number) Visited() bool {
	return n.visited
}

func (n *Number) MarkVisit() {
	n.visited = true
}

type Formula struct {
	position Coordinate
	Start    Coordinate
	End      Coordinate
	Area     int
	ToEval   int
	FinalV   int
	visited  bool
}

func NewFormula(r1 int, c1 int, r2 int, c2 int, v int, x int, y int) *Formula {
	return &Formula{
		position: Coordinate{x, y},
		Start:    Coordinate{r1, c1},
		End:      Coordinate{r2, c2},
		Area:     (r2 - r1) * (c2 - c1),
		ToEval:   v,
		FinalV:   -1,
		visited:  false,
	}
}

func (f *Formula) Coordinate() Coordinate {
	return f.position
}

func (f *Formula) Value() string {
	if f.FinalV != -1 {
		return strconv.Itoa(f.FinalV)
	}
	return "F"
}

func (f *Formula) Visited() bool {
	return f.visited
}

func (f *Formula) MarkVisit() {
	f.visited = true
}

func (f *Formula) nbCells() int {
	return f.Area
}

func (f *Formula) decrementArea() {
	f.Area--
}

type Unknown struct {
	position Coordinate
	visited  bool
}

func NewUnknown(x int, y int) *Unknown {
	return &Unknown{
		position: Coordinate{x, y},
		visited:  false,
	}
}

func (u *Unknown) Coordinate() Coordinate {
	return u.position
}

func (u *Unknown) MarkVisit() {
	u.visited = true
}

func (u *Unknown) Visited() bool {
	return u.visited
}

func (u *Unknown) Value() string {
	return consts.BAD_FORMAT
}
