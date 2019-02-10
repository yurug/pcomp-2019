package eval

import (
	"fmt"
	"strconv"
)

const BAD_FORMAT = "P"

type Cell interface {
	Coordinate() Coordinate
	Parents() []Coordinate
	Value() string
}

type Coordinate struct {
	X, Y int
}

type Number struct {
	position Coordinate
	value    int
}

func NewNumber(x int, y int, v int) (*Number, error) {
	if v < 0 || v > 255 {
		return nil, fmt.Errorf("Invalid value for Number type : Must have 0 <= v <= 255")
	}
	return &Number{
		position: Coordinate{x, y},
		value:    v,
	}, nil
}

func (n *Number) Coordinate() Coordinate {
	return n.position
}

func (n *Number) Value() string {
	return strconv.Itoa(n.value)
}

type Formula struct {
	position Coordinate
	Start    Coordinate
	End      Coordinate
	ToEval   int
}

func NewFormula(r1 int, c1 int, r2 int, c2 int, v int, x int, y int) *Formula {
	return &Formula{
		position: Coordinate{x, y},
		Start:    Coordinate{r1, c1},
		End:      Coordinate{r2, c2},
		ToEval:   v,
	}
}

func (f *Formula) Coordinate() Coordinate {
	return f.position
}

func (f *Formula) Value() string {
	return "F"
}

type Unknown struct {
	position Coordinate
	parents  []Coordinate
}

func NewUnknown(x int, y int) *Unknown {
	return &Unknown{
		position: Coordinate{x, y},
	}
}

func (u *Unknown) Coordinate() Coordinate {
	return u.position
}

func (u *Unknown) Parents() []Coordinate {
	return u.parents
}

func (u *Unknown) Value() string {
	return BAD_FORMAT
}
