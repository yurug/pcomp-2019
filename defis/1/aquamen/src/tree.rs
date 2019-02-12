use std::fs::File;
use std::io::Write;
use std::io::Read;
use std::rc::Rc;

use data::Point;
use data::Cell;
use data::Index;
use data::Data::*;
use data::Data;
use data::Function::*;

use log::*;

static NODE_MAX_SIZE: Index = 1_000;

// Idea: store the nodes in a vec
// and find a way to store them
// in a cache-friendly way

type Rectangle = (Point, Point);

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

pub struct Tree {
    // FIXME abstract away in Rect struct
    pub begin: Point,
    pub end: Point,
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
    trace!("Getting data between {:?} and {:?}", b, e);
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
        trace!("Reading cell {:?}", Cell{loc:Point{x:x,y:y},content:r});
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
    trace!("Building the sub leaf: ({:?}; {:?}) & ({:?}; {:?})", begin, mid, mid, end);
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
            x: end.x,
            y: (end.y  - begin.y) / 2,
        };
        trace!("Splitting content of leaf in {:?}", mid);
        Some(split_content(begin, end, &data, mid))
    } else {
        None
    }
}

fn split_leaf(begin: Point, end: Point, data: &mut Vec<Cell>) -> Content {
    let mid = Point {
        x: end.x,
        y: (end.y  - begin.y) / 2,
    };
    trace!("Splitting content of leaf in {:?}", mid);
    split_content(begin, end, &data, mid)
}

fn need_resize(rect: Rectangle, p: Point) -> bool {
    // If we need to make the area grow
    // e.g. adding a cell in a new line
    // (since we don't know beforehand the size of the sheet)
    let (begin, end) = rect;
    p.y > end.y
}

fn resize_for(rect: Rectangle, loc: Point) -> Rectangle {
    let (begin, end) = rect;
    (begin, Point{x: end.x, y: loc.y})
}

fn resize(begin: &mut Point, end: &mut Point, new: Point) {
    if need_resize((*begin, *end), new) {
        trace!("Resizing the leaf");
        let (b, e) = resize_for((*begin, *end), new);
        *begin = b; // FIXME find how to put self.*
        *end = e;     // in destructuring
    }
}

impl Tree {

    pub fn new() -> Tree {
        trace!("Creating Tree");
        Tree {
            begin: Point{x:0, y:0},
            end: Point{x:0, y:0},
            content: Content::Leaf {
                filename: String::new(),
                data: Vec::new(),
                dumped: false
            }
        }
    }



    pub fn add_cell(&mut self, cell: Cell) {
        let mut need_split = false;
        let c = match self.content {
            Content::Leaf{ref filename, ref mut data, ref mut dumped} => {
                trace!("Adding {:?} to the leaf", cell);

                resize(&mut self.begin, &mut self.end, cell.loc);

                if *dumped {
                    trace!("Reading data from {}", filename);
                    *data = read_data(self.begin, self.end, filename);
                }
                data.push(cell);

                if(data.len() > (NODE_MAX_SIZE as usize)) {
                    Some(split_leaf(self.begin, self.end, data))
                } else {
                    None
                }
            },
            Content::Node{ ref mut left, ref mut right } => {
                let end = (*left).end;
                let r = Rc::get_mut(right).unwrap();
                let l = Rc::get_mut(left).unwrap();
                if cell.loc.y > end.y {
                    r.add_cell(cell);
                } else {
                    l.add_cell(cell)
                }

                resize(&mut self.begin, &mut self.end, cell.loc);

                None
            }
        };
        match c {
            Some(c) => {
                trace!("The leaf need to be split");
                self.content = c;
                // If we need to split data, then dump them
                self.dump_data();
            },
            None => {}
        };
    }

    fn dump_data(&mut self) {
        trace!("Dumping data");
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
                trace!("Dumping in {}", filename);
                let mut file = File::create(filename).unwrap(); // FIXME better error management
                let mut res = Vec::new();
                for c in data {
                    trace!("Dumping {:?}", c);
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
                trace!("Dumping a node");
                Rc::get_mut(right).unwrap().dump_data();
                Rc::get_mut(left).unwrap().dump_data();
            }
        }
    }

    pub fn set_cell(&mut self, pos: Point, cell: Data) {
        match self.content {
            Content::Leaf{ref filename, ref mut data, ref dumped} => {
                trace!("Modifying cell at pos {:?}", pos);
                if *dumped {
                    *data = read_data(self.begin, self.end, filename);
                }
                for c in data {
                    if c.loc == pos {
                        trace!("Setting the cell at {:?}", pos);
                        c.content = cell;
                        return
                    }
                }
                // If the cell doesn't exists, add it
                // add_cell_leaf(self.begin, self.end, data, Cell{loc: pos, content: cell});
            },
            Content::Node{ref mut left, ref mut right} => {
                let end = (*left).end;
                let r = Rc::get_mut(right).unwrap();
                let l = Rc::get_mut(left).unwrap();
                if pos.y > end.y {
                    r.set_cell(pos, cell)
                } else {
                    l.set_cell(pos, cell)
                }
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
                if pos.y > end.y {
                    r.get_cell(pos)
                } else {
                    l.get_cell(pos)
                }
            }
        }
    }

    // Interface for spreadsheet to make sure
    // we don't have to much changes to do
    pub fn get(&mut self, pos: Point) -> Option<Cell> {
        self.get_cell(pos)
    }

    pub fn insert(&mut self, pos: Point, cell: Data) {
        match self.get(pos) {
            None => self.add_cell(Cell{loc: pos, content: cell}),
            Some(_) => self.set_cell(pos, cell),
        }
    }
}

