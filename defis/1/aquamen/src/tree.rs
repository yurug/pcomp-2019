use std::fs::File;
use std::io::Write;
use std::io::Read;
use std::rc::Rc;

use data::Point;
use data::Cell;
use data::Index;
use data::Data::*;
use data::Function::*;

static NODE_MAX_SIZE: Index = 1000000;

// Idea: store the nodes in a vec
// and find a way to store them
// in a cache-friendly way

enum Content {
    Leaf {
        // Generated when dumping data
        filename: String,
        // Cell waiting to be dumped on disk
        // Used when filling the node (before dumping variables)
        // or before computation (when we need to load vars)
        // FIXME option for when there is no data ?
        data: Vec<Cell>,
        dumped: bool,
    },
    Node {
        left: Rc<Tree>,
        right: Rc<Tree>,
    }
}

struct Tree {
    // FIXME abstract away in Rect struct
    begin: Point,
    end: Point,
    content: Content,
}


fn area(b: Point, e: Point) -> Index {
    (e.x - b.x) * (e.y - b.y)
}

fn contained_in(p: Point, b: Point, e: Point) -> bool {
    p.x > b.x
        && e.x > p.x
        && p.y > b.y
        && e.y > p.y
}

fn split_data(data: &Vec<Cell>, b: Point, e: Point) -> Vec<Cell> {
    data.iter()
        .filter( |c| contained_in(c.loc, b, e) )
        .map(|c| c.clone())
        .collect()
}

fn read_data(begin: Point, end: Point, filename: &String) -> Vec<Cell> {
    let mut file = File::open(filename).unwrap(); // FIXME better error management
    let mut res: Vec<u8> = Vec::new();
    file.read(&mut res).unwrap();
    let mut cpt = 0;
    let mut x = begin.x;
    let mut y = begin.y;
    let mut data = Vec::new();
    while cpt < res.len() {
        let t = res[cpt];
        let v = res[cpt+1];
        let r = match t {
            0 => Val(v),
            1 => Fun(Count(Point{x:0,y:0}, Point{x:0,y:0}, 0)),
            2 => Wrong,
            _ => panic!("Unexpected value in data dump")
        };
        data.push(Cell{
            content: r,
            loc: Point{x: x, y: y},
        });
        if x <= end.x {
            x += 1;
        } else {
            x = begin.x;
            y += 1;
        }
        cpt += 2;
    }
    data
}

fn split_content(begin: Point, end: Point, data: &Vec<Cell>, mid: Point) -> Content {
    Content::Node {
        left: Rc::new(Tree{
            begin: begin,
            end: mid,
            content: Content::Leaf {
                dumped: false,
                filename: String::new(),
                data: split_data(&data, begin, mid)
            }
        }),
        right: Rc::new(Tree{
            begin: mid,
            end: end,
            content: Content::Leaf {
                dumped: false,
                filename: String::new(),
                data: split_data(&data, mid, end)
            }
        })
    }
}

fn add_cell_leaf(begin: Point, end: Point, data: &mut Vec<Cell>, cell: Cell) -> Option<Content> {
    data.push(cell);
    if data.len() > (NODE_MAX_SIZE as usize) {
        let mid = Point {
            x: (end.x  - begin.x) / 2,
            y: (end.y  - begin.y) / 2,
        };
        Some(split_content(begin, end, &data, mid))
    } else {
        None
    }
}



impl Tree {
    // FIXME dump data when needed

    pub fn add_cell(&mut self, cell: Cell) {
        let c = match self.content {
            Content::Leaf{ref filename, ref mut data, ref mut dumped} => {
                if *dumped {
                    *data = read_data(self.begin, self.end, filename);
                }
                add_cell_leaf(self.begin, self.end, data, cell)
            },
            Content::Node{ ref mut left, ref mut right } => {
                let end = (*left).end;
                let r = Rc::get_mut(right).unwrap();
                let l = Rc::get_mut(left).unwrap();
                if cell.loc.x > end.x {
                    r.add_cell(cell);
                } else if cell.loc.y > end.y {
                    r.add_cell(cell);
                } else {
                    l.add_cell(cell)
                }
                None
            }
        };
        match c {
            Some(c) => {
                self.content = c;
                // If we need to split data, then dump them
                self.dump_data();
            },
            None => {}
        };
    }

    fn dump_data(&mut self) {
        match self.content {
            Content::Leaf{ ref mut filename, ref mut data, ref mut dumped } => {
                *dumped = true;
                if filename.len() == 0 {
                    *filename = format!("{}.{}.{}.{}.cells",
                                self.begin.x,
                                self.begin.y,
                                self.end.x,
                                self.end.y)
                };
                let mut file = File::create(filename).unwrap(); // FIXME better error management
                let mut res = Vec::new();
                for c in data {
                    match c.content {
                        Val(i) => {
                            res.push(0);
                            res.push(i);
                        },
                        Fun(_) => {
                            res.push(1);
                            res.push(0);
                        },
                        Wrong => {
                            res.push(2);
                            res.push(0);
                        },
                    }
                }
                file.write_all(&res);
            },
            Content::Node{ref mut left, ref mut right} => {
                Rc::get_mut(right).unwrap().dump_data();
                Rc::get_mut(left).unwrap().dump_data();
            }
        }
    }

    pub fn get_cell(&mut self, pos: Point) -> Option<Cell> {
        match self.content {
            Content::Leaf{ref filename, ref mut data, ref dumped} => {
                if *dumped {
                    *data = read_data(self.begin, self.end, filename);
                }
                for c in data {
                    if c.loc == pos {
                        return Some(*c)
                    }
                }
                None
            },
            Content::Node{ref mut left, ref mut right} => {
                let end = (*left).end;
                let r = Rc::get_mut(right).unwrap();
                let l = Rc::get_mut(left).unwrap();
                if pos.x > end.x {
                    r.get_cell(pos)
                } else if pos.y > end.y {
                    r.get_cell(pos)
                } else {
                    l.get_cell(pos)
                }
            }
        }
    }

    // // Assume that content is a Leaf
    // // Can't split Node since it doesn't contains "data"
    // fn split(&mut self) {
    //     let mid = Point {
    //         x: (self.end.x  - self.begin.x) / 2,
    //         y: (self.end.y  - self.begin.y) / 2,
    //     };
    //     let new = match self.content {
    //         Content::Leaf{ filename: _, ref data, dumped:_ } => {
    //             self.split_content(&data, mid)
    //         },
    //         _ => panic!("Trying to split a non-Leaf Node !")
    //     };
    //     self.content = new;
    // }
}
