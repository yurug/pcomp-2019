package structs

const KIND_FORMULA = "formula"
const KIND_INTEGER = "integer"

type Coordinate struct {
	X, Y int
}

type Cell struct {
	Kind string
	Crd Coordinate
	Value string
}

type Line struct {
	Cells []Cell
}

type Formula struct {
	Start Coordinate
	End Coordinate
	Value int
}
