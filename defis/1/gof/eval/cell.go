package eval

import "fmt"

type Cell interface {
	Coordinate() Coordinate
	Parents() []Cell
}

type Coordinate struct {
	X, Y int
}

type Number struct {
	position Coordinate
	Value    int
	parents  []Cell
}

func NewNumber(x int, y int, v int) (*Number, error) {
	if v < 0 || v > 255 {
		return nil, fmt.Errorf("Invalid value for Number type : Must have 0 <= v <= 255")
	}
	return &Number{
		position: Coordinate{x, y},
		Value:    v,
	}, nil
}

func (n *Number) Coordinate() Coordinate {
	return n.position
}

func (n *Number) Parents() []Cell {
	return n.parents
}

type Formula struct {
	position Coordinate
	Start    Coordinate
	End      Coordinate
	ToEval   int
	parents  []Cell
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

func (f *Formula) Parents() []Cell {
	return f.parents
}
