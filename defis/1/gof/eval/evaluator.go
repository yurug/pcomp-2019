package eval

import (
	"fmt"
	"os"

	"github.com/yurug/pcomp-2019/defis/1/gof/cell"
	"github.com/yurug/pcomp-2019/defis/1/gof/db"
)

type Evaluator struct {
	target *os.File
}

func newEvaluator(targetPath string) (*Evaluator, error) {
	f, err := os.Create(targetPath)
	if err != nil {
		return nil, err
	}
	return &Evaluator{
		target: f,
	}, nil
}

func FirstEvaluation(target string, fd *db.FileDescriptor) error {
	e, err := newEvaluator(target)
	if err != nil {
		return err
	}
	process(fd)
	return nil
}

func (e *Evaluator) serialize() {
	fmt.Println("Serialize..")
	for _, line := range e.m {
		for i, cell := range line {
			if i == len(line)-1 {
				e.target.WriteString(cell.Value())
			} else {
				e.target.WriteString(cell.Value())
				e.target.WriteString(";")

			}
		}
		e.target.WriteString("\n")
	}
	return
}

func process(fd *db.FileDescriptor) error {
	for {
		line, count := fd.NextLine()
		if count == 0 {
			break
		}

	}
	return nil
}

func (e *Evaluator) Process(ch chan []cell.Cell, doneEval chan int) {
	fmt.Println("Process..")
	e.initMatrix(ch)
	for r, line := range e.m {
		for c, cell := range line {
			switch v := cell.(type) {
			default:
				continue
			case *cell.Formula:
				var num Cell
				valueAfterEval, err := e.eval(Cell(v), v.ToEval, 0)
				if err != nil {
					fmt.Println(err)
					num = NewUnknown(r, c)
					e.m[r][c] = num
					continue
				}
				num, err = NewNumber(r, c, valueAfterEval)
				if err != nil {
					num = NewUnknown(r, c)
				}
				e.m[r][c] = num

			}
		}
	}
	e.serialize()
	doneEval <- 1
}

func (e *Evaluator) eval(c cell.Cell, param int, occ int) (int, error) {
	switch v := c.(type) {
	case *Unknown:
		return 0, nil
	case *Number:
		if v.value == param {
			return 1, nil
		}
		return 0, nil
	case *cell.Formula: //Call recursively e.val() to count the occurence of the parameter
		//check if presence of a cyclic graph
		coord := c.Coordinate()
		if e.m[coord.X][coord.Y].Visited() {
			if v.FinalV != -1 {
				return v.FinalV, nil
			}
			return -1, fmt.Errorf("Error occured in method eval: cyclic graph detected")
		}
		//add the current cell to the visited cells
		e.m[coord.X][coord.Y].MarkVisit()

		for i := v.Start.X; i <= v.End.X; i++ {
			for j := v.Start.Y; j <= v.End.Y; j++ {
				val, err := e.eval(e.m[i][j], param, occ)
				if err != nil {
					fmt.Println(err)
					return -1, err
				}
				occ += val
				v.FinalV = val
			}
		}
	}
	return occ, nil
}

//on suppose qu'on a tt les cellules chargées en mémoires
//fonction fait par l'utilisateur pour modifier une cellule par un int
func userPutValue(val int, x int, y int, values [][]cell.Cell) error {
	number, err := NewNumber(x, y, val)
	if err != nil {
		return err
	}
	values[x][y] = number
	return err
}

//fonction fait par l'utilisateur pour modifier une cellule par une formule
func userPutFormul(r1 int, c1 int, r2 int, c2 int, v int,
	x int, y int, values [][]cell.Cell) {
	formula := NewFormula(r1, c1, r2, c2, v, x, y)
	values[x][y] = formula

}

//fonction qui inverse la case de depart et la case d'arrive,
func reformateFormule(f *cell.Formula) {
	if f.Start.X > f.End.X {
		tmp := f.Start.X
		f.Start.X = f.End.X
		f.End.X = tmp
		tmp = f.Start.Y
		f.Start.Y = f.End.Y
		f.End.Y = tmp
	}
}
