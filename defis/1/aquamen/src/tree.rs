
use std::rc::Rc;

use data::Point;
use data::Cell;
use data::Index;

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

impl Tree {
    // public functions:
    // add_cell
    // get_cell

    // private functions:
    // dump memory
    // 

    pub fn add_cell(&mut self, cell: Cell) {
        match self.content {
            Content::Leaf{filename: _, ref mut data} => {
                data.push(cell);
                if data.len() > (NODE_MAX_SIZE as usize) {
                    self.split()
                }
            },
            Content::Node{ ref mut left, ref mut right } => {
                let end = (*left).end;
                if cell.loc.x > end.x {
                    (*right).add_cell(cell);
                } else if cell.loc.y > end.y {
                    (*right).add_cell(cell);
                } else {
                    (*left).add_cell(cell)
                }
            }
        }
    }

    // pub fn get_cell(&self, pos: Point) -> Cell {
    //     match self.content {
    //         Content::Leaf{filename: _, data} => {
                
    //         }
    //     }
    // }

    fn split_data(&self, data: &Vec<Cell>, b: Point, e: Point) -> Vec<Cell> {
        data.iter()
            .filter( |c| contained_in(c.loc, b, e) )
            .map(|c| c.clone())
            .collect()
    }

    fn split_content(&self, data: &Vec<Cell>, mid: Point) -> Content {
        Content::Node {
            left: Rc::new(Tree{
                begin: self.begin,
                end: mid,
                content: Content::Leaf {
                    filename: String::new(),
                    data: self.split_data(&data, self.begin, mid)
                }
            }),
            right: Rc::new(Tree{
                begin: mid,
                end: self.end,
                content: Content::Leaf {
                    filename: String::new(),
                    data: self.split_data(&data, mid, self.end)
                }
            })
        }
    }

    // Assume that content is a Leaf
    // Can't split Node since it doesn't contains "data"
    fn split(&mut self) {
        let mid = Point {
            x: (self.end.x  - self.begin.x) / 2,
            y: (self.end.y  - self.begin.y) / 2,
        };
        let new = match self.content {
            Content::Leaf{ filename: _, ref data } => {
                self.split_content(&data, mid)
            },
            _ => panic!("Trying to split a non-Leaf Node !")
        };
        self.content = new;
    }
}
