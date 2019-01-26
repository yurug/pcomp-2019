use combine::attempt;
use combine::parser::char::{digit, spaces, string};
use combine::parser::repeat::many;
use combine::parser::repeat::skip_until;
use combine::{between, choice, from_str, many1, token, value, Parser, Stream};
use data::Data::{Fun, Val, Wrong};
use data::Function::Count;
use data::Num;
use data::{Cell, Data, Point};
use combine::parser::item::Token ;

const CSEP: char = ';';
const LCOUNT: &'static str = "=#(";
const RCOUNT: char = ')';
const SEP_COUNT: char = ',';

parser! {
    fn num[I]()(I) -> Num where [I: Stream<Item = char>] {
        from_str(many1::<String, _>(digit()))
    }
}

parser! {
    fn val[I]()(I) -> Data where [I: Stream<Item = char>] {
        num().map(Val)
    }
}

parser! {
    fn coord[I]()(I) -> u64 where [I: Stream<Item = char>] {
        spaces().with(from_str(many1::<String, _>(digit())))
    }
}

parser! {
    fn count[I]()(I) -> Data where [I: Stream<Item = char>]
    {

        let p = (coord().skip(token(SEP_COUNT)),
                 coord().skip(token(SEP_COUNT)),
                 coord().skip(token(SEP_COUNT)),
                 coord().skip(token(SEP_COUNT)),
                 num())
            .map(|t| Fun(Count(Point{x:t.0,y:t.1},
                               Point{x:t.2,y:t.3},
                               t.4)));

        between(string(LCOUNT),token(RCOUNT), p)
    }
}

parser! {
    fn wrong[I]()(I) -> Data where [I: Stream<Item = char>] {
        // ajouter la gestion de la fin de ligne
        skip_until(token(CSEP)).with(value(Wrong))
    }
}

parser! {
    fn data[I]()(I) -> Data where [I: Stream<Item = char>] {
        choice!(
            attempt(val()),
            attempt(count()),
            wrong()
        )
    }
}

parser! {
    fn data_line[I]()(I) -> Vec<Data> where [I: Stream<Item = char>] {
        many(choice!(
            attempt(data().skip(token(CSEP))),
            data())
        )
    }
}

pub fn parse_cvs(line: u64, s: &str) -> Vec<Cell> {
    let res = data_line().easy_parse(s);
    let v = match res {
        Ok((v, _)) => v,
        _ => panic!("What a dirty parser !"),
    };
    let mut cell_vec = Vec::new();
    for i in 0..(v.len()) {
        cell_vec.push(Cell {
            content: v[i].clone(),
            loc: Point {
                x: (i as u64),
                y: line,
            },
        });
    }
    cell_vec
}

#[cfg(test)]
mod tests {

    use super::*;
    
    #[test]
    fn test_simple_val() {
        assert_eq!(
            parse_cvs(0,"12"),
            vec![Cell{content:Val(12),loc:Point{x:0,y:0}}]
        );
    }
}
