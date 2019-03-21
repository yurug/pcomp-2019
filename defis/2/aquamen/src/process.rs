use std::sync::mpsc::Sender;

use aprinter::APrinter ;
use data::{Cell,Point,Index};
use parser::parse_line;
use parser::parse_change;
use spreadsheet::Spreadsheet;

type Requirement = Cell;

pub struct Processor {
    line_len : Index,
    sheet : Spreadsheet,
    printer : APrinter,
    mychannel : Sender<Requirement>,
    waiting : Vec<Point>
}

impl Processor {

    pub fn new(printer : APrinter,  mychannel : Sender<Requirement>)
               -> Processor {
        let ll = printer.cells_by_line() ;
        let sheet = Spreadsheet::new(ll);
        Processor {
            line_len : ll,
            sheet : sheet,
            printer : printer,
            mychannel : mychannel,
            waiting : vec![]
        }
    }
    
    pub fn initial_valuation(&mut self,buffer : String, line_offset : Index) {
        let it = buffer.split("\n").filter(|x| x.len() > 0) ;
        let line_num = it.clone().count() ;
        for (i,line) in it.enumerate() {
            let cells = parse_line(i as Index + line_offset,line) ;
            for c in cells {
                self.sheet.add_cell(c) ;
            }
        }
        for i in 0..line_num {
            for j in 0..self.line_len {
                let p = Point{x:j as Index,y:i as Index + line_offset};
                let ov = self.sheet.eval(p) ;
                if ov.is_none() {
                    self.waiting.push(p) ;
                } else {
                    let c = Cell{content:ov.unwrap(),loc:p};
                    self.printer.print(c);
                }
            }
        }
        self.try_again();
    }

    fn try_again(&mut self) {

        let mut future = vec![] ;
        
        for p in &self.waiting {
            let v = self.sheet.eval(*p) ;
            if v.is_none() {
                future.push(*p) ;
            } else {
                let c = Cell{content:v.unwrap(),loc:*p};
                self.printer.print(c);
            }
        }
        self.waiting = future ;
    }
    
    pub fn changes(&mut self,buffer : String) {
        let mut lines: Vec<&str> = buffer.split("\n").collect();
        lines.pop();

        let changes: Vec<Cell> = lines.into_iter()
            .map(|l| parse_change(l))
            .collect();

        let effects: Vec<(Cell, Vec<Cell>)> = changes.into_iter()
            .map(|cell| self.sheet.apply_change(cell))
            .collect();
    
        self.printer.print_changes(effects);
    }
}
