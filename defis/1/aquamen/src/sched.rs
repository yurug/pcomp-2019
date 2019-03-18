use std::sync::mpsc::channel;
use std::fs;
use std::fs::File;
use std::io::{BufReader,BufRead} ;

use process::Processor;
use parser::parse_line;
use aprinter::APrinter;


use bench::bench;

// FIXME test!!!!

pub fn schedule(sheet_path: &str,
                user_mod_path: &str,
                view0_path: &str,
                changes_path: &str,
                bench: bench::Sender) {

    /* On récupère la largeur du parser (en parsant la première ligne). */
    let line_len = guess_line_len(sheet_path) ;

    /* On s'en sert pour construire le printer, à partir duquel on peut
       construire le premier (dans cette implémentation, le seul) thread du
       programme.*/
    let mut sheet = BufReader::new(File::open(sheet_path).unwrap());
    let printer =  APrinter::new(view0_path.to_string(),
                                 changes_path.to_string(),
                                 line_len as u64) ;
    let (sender, _recv) = channel();
    let mut proc = Processor::new(printer, sender);

    /* On lit le fichier d'entrée ligne par ligne, en fournissant chaque ligne
       au(x) thread(s) qui va la traiter. On pourrait également lui
       transmettre des blocs de x lignes. */
    let mut line_offset = 0 ;
    let mut res = Ok(1);
    while res.unwrap() > 0 {
        let mut line = String::new() ;
        res = sheet.read_line(&mut line) ;
        proc.initial_valuation(line, line_offset) ;
        line_offset += 1 ;
    }

    /* On indique au thread qu'il a reçu toutes les données dont il a besoin
       pour finir. */
    proc.try_again() ;
    
    /* On lit et calcule les changements d'une traite.*/
    let changes = fs::read_to_string(user_mod_path)
        .expect("Something went wrong reading the second file");
    proc.changes(changes);
}

fn guess_line_len(sheet_path: &str) -> usize {
    let sheet = BufReader::new(File::open(sheet_path).unwrap());
    let line : String = sheet.lines().next().unwrap().unwrap() ;
    parse_line(0,&*line).len()
}
