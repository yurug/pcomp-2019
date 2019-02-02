package eval

import "fmt"

const BAD_FORMAT = "P"

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

func (f *Formula) isChild(c Cell) bool {
	return f.End.X >= c.Coordinate().X && // r2 > x
		c.Coordinate().X >= f.Start.X && // x > r1
		f.End.Y >= c.Coordinate().Y && // c2 > x
		c.Coordinate().Y >= f.Start.Y // x > c1
}

type Unknown struct {
	position Coordinate
	parents  []Cell
}

func NewUnknown(x int, y int) *Unknown {
	return &Unknown{
		position: Coordinate{x, y},
	}
}

func (u *Unknown) Coordinate() Coordinate {
	return u.position
}

func (u *Unknown) Parents() []Cell {
	return u.parents
}

func (u *Unknown) Value() string {
	return BAD_FORMAT
}
