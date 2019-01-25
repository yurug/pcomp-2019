use combine::parser::char::{spaces, digit, char};
use combine::{choice,from_str,many1,Parser,sep_by,token,position,Stream};
use combine::error::ParseError;
use data::{Point,Cell};
use data::Data::{Val};

parser!{
    fn num[I]()(I) -> Cell
    where [
        I: Stream<Item = char>,
        I::Error: ParseError<char, I::Range, I::Position>,
        <I::Error as ParseError<I::Item, I::Range, I::Position>>::StreamError:
            From<::std::num::ParseIntError>,
    ]
    {
        (position(),from_str(many1::<String, _>(digit())))
            .map(|(_,b) : (I::Position,u8)| {
            Cell{content:Val(b),loc:Point{x:0,y:0}}
        })
    }
}

parser!{
    fn data_vec[I]()(I) -> Vec<Cell>
    where [
        I: Stream<Item = char>,
        I::Error: ParseError<char, I::Range, I::Position>,
        <I::Error as ParseError<I::Item, I::Range, I::Position>>::StreamError:
            From<::std::num::ParseIntError>,
    ]
    {
        sep_by(choice!(
            num()
        ), token(','))
    }
}


pub fn run() {
    println!("{:?}", data_vec().easy_parse("123,12"));
}
