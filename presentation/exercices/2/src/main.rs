
#[derive(Clone, Copy, Debug)]
struct Point {
    x: u64,
    y: u64,
}

#[derive(Clone, Copy, Debug)]
enum Cell {
    Val(u8),
    Fun(Point, Point, u8),
}

type Matrix = Vec<Vec<Cell>>;

struct Spreadsheet {
    pub vals: Matrix
}

impl Spreadsheet {
    pub fn new(width: u64, height: u64) -> Spreadsheet {
        Spreadsheet {
            vals: vec![vec![Cell::Val(0); width as usize]; height as usize]
        }
    }

    pub fn add(&mut self, pos: Point, cell: Cell) {
        self.vals[pos.y as usize][pos.x as usize] = cell
    }

    fn eval_at(&mut self, x:u64, y:u64, v:u8) -> u8 {
        match self.vals[y as usize][x as usize] {
            Cell::Val(i) => if i == v {
                1
            } else {
                0
            },
            Cell::Fun(b, e, v2) => {
                let mut cpt = 0;
                for x in b.x..e.x {
                    for y in b.y..e.y {
                        cpt += self.eval_at(x, y, v2);
                    }
                }
                self.vals[y as usize][x as usize] = Cell::Val(cpt);
                if cpt == v {
                    1
                } else {
                    0
                }
            },
        }
    }

    pub fn eval(&mut self) {
        for line in &self.vals {
            for cell in line {
                match cell {
                    Cell::Val(_) => {},
                    Cell::Fun(b, e, v) => {
                        let mut cpt = 0;
                        for x in b.x..e.x {
                            for y in b.y..e.y {
                                cpt += self.eval_at(x, y, *v);
                            }
                        }
                        *cell = Cell::Val(cpt);
                    },
                }
            }
        }
    }
}

fn main() {
    let mut sheet = Spreadsheet::new(10, 10);
    for x in 0..10 {
        for y in 0..10 {
            sheet.add(Point{x:x, y:y}, Cell::Val((x+y) as u8))
        }
    }
    sheet.add(Point{x:5, y:5},
              Cell::Fun(Point{x:0,y:0},
                        Point{x:5,y:5},
                        3));
    sheet.add(Point{x:7, y:5},
              Cell::Fun(Point{x:5,y:5},
                        Point{x:10,y:10},
                        1));
    for x in 0..10 {
        for y in 0..10 {
            print!("{:?},", sheet.vals[y][x])
        }
        print!("\n")
    }
}
