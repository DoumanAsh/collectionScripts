///Script to calculate checksums
extern crate crypto;

use crypto::digest::Digest;
use crypto::md5::Md5;
use crypto::sha1::Sha1;
use crypto::sha2::{Sha256, Sha512};

use std::env::args as cmd_args;
use std::fs::{read_dir, metadata};
use std::io::{Read, BufReader};

#[inline(always)]
fn usage() {
println!("Usage: hash_sum [options] <input>...

Options:
    --md5       Enables md5 calculation.
    --sha1      Enables sha1 calculation.
    --sha256    Enables sha256 calculation.
    --sha512    Enables sha512 calculation.
");
}

//Buffer size 10kbs
const BUFFER_SIZE: usize = 10000;

macro_rules! is_file {
    ($path:expr) => { std::fs::metadata($path).unwrap().is_file() }
}

macro_rules! input {
    ($msg:expr) => {{
        use std::io::{Read, Write};
        print!($msg);
        std::io::stdout().flush().unwrap();
        std::io::stdin().bytes().next();
    }}
}

struct Checksum(String, Box<Digest>);

impl Checksum {
    #[inline(always)]
    pub fn input(&mut self, slice_content: &[u8]) { self.1.input(slice_content); }
    #[inline(always)]
    pub fn result(&mut self) -> String { format!("{:8}{}", self.0, self.1.result_str()) }
    #[inline(always)]
    pub fn reset(&mut self) { self.1.reset(); }
}

impl PartialEq for Checksum {
    fn eq(&self, right: &Checksum) -> bool {
        self.0 == right.0
    }

    fn ne(&self, right: &Checksum) -> bool {
        self.0 != right.0
    }
}

struct HashSum(Vec<String>, Vec<Checksum>);

impl HashSum {
    #[inline(always)]
    fn default_algos(&mut self) {
        self.1.push(Checksum("MD5:".to_string(), Box::new(Md5::new())));
        self.1.push(Checksum("SHA1:".to_string(), Box::new(Sha1::new())));
        self.1.push(Checksum("SHA256:".to_string(), Box::new(Sha256::new())));
        self.1.push(Checksum("SHA512:".to_string(), Box::new(Sha512::new())));
    }

    #[inline(always)]
    fn reset_algos(&mut self) {
        for algo in self.1.iter_mut() {
            algo.reset();
        }
    }

    pub fn run_from_args() {
        let mut hash_sum = HashSum(Vec::new(), Vec::new());

        for arg in cmd_args().skip(1) {
            if arg.starts_with("-") {
                match arg.as_ref() {
                    "--md5" => hash_sum.1.push(Checksum("MD5:".to_string(), Box::new(Md5::new()) as Box<Digest>)),
                    "--sha1" => hash_sum.1.push(Checksum("SHA1:".to_string(), Box::new(Sha1::new()) as Box<Digest>)),
                    "--sha256" => hash_sum.1.push(Checksum("SHA256:".to_string(), Box::new(Sha256::new()) as Box<Digest>)),
                    "--sha512" => hash_sum.1.push(Checksum("SHA512:".to_string(), Box::new(Sha512::new()) as Box<Digest>)),
                    arg @ _ => println!(">>>Invalid flag {}", arg),
                }
            }
            else { hash_sum.0.push(arg) }
        }

        if hash_sum.1.len() == 0 { hash_sum.default_algos(); }

        hash_sum.run()
    }

    fn run(&mut self) {
        for arg in self.0.clone() {
            if let Ok(arg_meta_data) = metadata(&arg) {
                if arg_meta_data.is_file() {
                    self.calc(&arg);
                }
                else if let Ok(dir_content) = read_dir(&arg) {
                    for entry_path in dir_content.map(|entry| entry.unwrap().path()) {
                        if is_file!(&entry_path) { self.calc(&entry_path.to_str().unwrap()); }
                    }
                }
                else {
                    println!(">>>{}: cannot access content of this dir", &arg);
                    continue;
                }
            }
            else {
                println!(">>>{}: cannot access file/directory", &arg);
                continue;
            }
        }
    }

    fn calc(&mut self, path: &str) {
        self.reset_algos();
        if let Ok(file) = std::fs::File::open(&path) {
            let mut file = BufReader::new(file);
            println!(">>>{}:", &path);
            loop {
                let mut file_content: [u8; BUFFER_SIZE] = [0; BUFFER_SIZE];
                let read_bytes = file.read(&mut file_content).unwrap();
                if read_bytes == 0 { break; }

                //In case if read is unable to fill buffer completely.
                let slice_content = &file_content[..read_bytes];
                for algo in self.1.iter_mut() {
                    algo.input(slice_content);
                }
            }

            for algo in self.1.iter_mut() {
                println!("{}", algo.result());
            }
            println!("=======================================================\n");
        }
        else {
            println!(">>>{}: failed to open", &path);
        }
    }
}

fn main() {
    if cmd_args().len() < 2 { return usage(); }

    HashSum::run_from_args();

    //this is done mostly for convenient drag and drop.
    if cfg!(windows) {
        input!("Press Enter to exit...");
    }
}
