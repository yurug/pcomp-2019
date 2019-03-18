use std::fs::File;
use std::fs::create_dir_all;
use std::io::Write;
use std::io::Read;
use bench;
use log::*;
use std::path::Path;
use data::Cell;
use data::Data::*;
use data::*;
use data::Index;
use data::Point;
use data::Function::*;

pub fn read_data(begin: Point, end: Point, filename: &String) -> Vec<Cell> {
    let f = format!("{}.cells", filename);
    let mut file = File::open(f).unwrap(); // FIXME better error management
    let mut res: Vec<u8> = Vec::new();
    file.read_to_end(&mut res).unwrap();
    let mut cpt = 0;
    let mut x = begin.x;
    let mut y = begin.y;
    let mut data = Vec::new();
    trace!("{} elements in {}.cells", res.len(), filename);
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
        bench::bench::get_sender().send(1);
        data.push(Cell{
            content: r,
            loc: Point{x: x, y: y},
        });
        if x < end.x-1 {
            x += 1;
        } else {
            x = begin.x;
            y += 1;
        }
        cpt += 2;
    }
    data
}

// FIXME put magic value in enum or in cste ?
pub fn dump_val_to(i: u8, dest: &mut Vec<u8>) {
    dest.push(0);
    dest.push(i);
}

pub fn dump_fun_to(dest: &mut Vec<u8>) {
    dest.push(1);
    dest.push(0);
}

pub fn dump_wrong_to(dest: &mut Vec<u8>) {
    dest.push(2);
    dest.push(0);
}

// Consume the data
pub fn dump_cells(filename: &String, data: Vec<Cell>) {
    trace!("Dumping in {}.cells", filename);
    create_dir_all(Path::new(&filename)
                   .parent()
                   .unwrap()
                   .to_str()
                   .unwrap()).unwrap();
    let mut file = File::create(format!("{}.cells",filename)).unwrap(); // FIXME better error management
    let mut res = Vec::new();
    trace!("Writing data of node {} : {:?} ", filename, data);
    for c in data {
        bench::bench::get_sender().send(-1);
        trace!("Dumping {:?}", c);
        match c.content {
            Val(i) => dump_val_to(i, &mut res),
            Fun(_) => dump_fun_to(&mut res),
            Wrong  => dump_wrong_to(&mut res),
        }
    }
    trace!("Writing cells of node {} : {:?} ", filename, res);
    file.write_all(&res);
}

#[cfg(test)]
mod tests {

    use data::Point;
    use serialize::*;

    #[test]
    fn dump_and_read() {
        let num_cell = 10;
        let mut cells = Vec::with_capacity((num_cell as usize) * (num_cell as usize));
        let mut c = Vec::with_capacity((num_cell as usize) * (num_cell as usize));

        for j in 0..num_cell {
            for i in 0..num_cell {
                cells.push((i, j))
            }
        }

        for (i, j) in &cells {
            c.push(Cell{
                loc: Point{x:*i as u64, y:*j as u64},
                content: Val(*i + *j),
            });
        }

        let cp = c.clone();

        let f = "/tmp/data.cells".to_owned();
        dump_cells(&f, c);
        let b = Point{x:0, y:0};
        let e = Point{x:num_cell as u64, y:num_cell as u64};
        let new = read_data(b, e, &f);
        assert!(new.len() == cp.len());
        for (o, n) in cp.iter().zip(new.iter()) {
            println!("{:?} == {:?}", o, n);
            assert!(o == n);
        }

    }
}
