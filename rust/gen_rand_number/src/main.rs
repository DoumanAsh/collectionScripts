extern crate rand;
use rand::{thread_rng};
use rand::distributions::{IndependentSample, Range};
use std::env::args as cmd_args;

#[inline(always)]
fn usage() {
    println!("Usage:");
    println!("    gen_random [number of digits]");
}

fn gen_random_number_string(number: usize) -> String {
    let num_range = Range::new(0, 9);
    let mut rng = rand::thread_rng();
    let mut final_string = String::with_capacity(number);
    for _ in 0..number {
        final_string.push_str(format!("{}", num_range.ind_sample(&mut rng)).as_ref());
    }
    final_string
}

fn main() {
    if let Some(arg1) = cmd_args().skip(1).next() {
        if let Ok(arg1_number) = arg1.parse::<usize>() {
            if arg1_number == 0 { return; }

            println!("Got number: {}", gen_random_number_string(arg1_number));
        }
        else {
            println!("Cannon parse >{}< into positive number", &arg1);
        }
    }
    else { usage() }
}
