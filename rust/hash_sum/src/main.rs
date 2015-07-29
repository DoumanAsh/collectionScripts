///Script to calculate checksums
extern crate crypto;

use crypto::digest::Digest;
use crypto::md5::Md5;
use crypto::sha1::Sha1;
use crypto::sha2::{Sha256, Sha512};

use std::env::args as cmd_args;
use std::fs::{read_dir, metadata};
use std::io::{Read, Write, BufReader};

#[inline(always)]
fn usage() {
println!("Usage: hash_sum [-c | -o | -p] [algorithms] <input>...

Algorithms:
    --md5       Enables md5 calculation.
    --sha[num]  Enables sha calculation. num can be [1, 256, 512]

Mode:
    Mutually exclusive.
    -c --check  Verifies checksum from files.
    -o --output Write calculations into files with corresponding extension.
    -p --print  Prints checksums to stdout. Default.
");
}

fn invalid_usage(text: &str) {
    println!("{}", text);
    usage();
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
    pub fn get_checksum(&mut self) -> String { self.1.result_str() }
    #[inline(always)]
    pub fn reset(&mut self) { self.1.reset(); }
    #[inline(always)]
    pub fn get_file_ext(&self) -> String { self.0[0..self.0.len()-1].chars().map(|elem| elem.to_lowercase().next().unwrap()).collect() }
    #[inline(always)]
    pub fn get_type_string(&self) -> String { format!("{:8}", self.0) }
}

impl PartialEq for Checksum {
    fn eq(&self, right: &Checksum) -> bool {
        self.0 == right.0
    }

    fn ne(&self, right: &Checksum) -> bool {
        self.0 != right.0
    }
}

enum FlagType {
    Print,
    Output,
    Check,
}

struct HashSum(Vec<String>, Vec<Checksum>, FlagType);

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

    fn sha_match(&mut self, arg: &str) -> bool {
        match arg {
            "1" => self.1.push(Checksum("SHA1:".to_string(), Box::new(Sha1::new()) as Box<Digest>)),
            "256" => self.1.push(Checksum("SHA256:".to_string(), Box::new(Sha256::new()) as Box<Digest>)),
            "512" => self.1.push(Checksum("SHA512:".to_string(), Box::new(Sha512::new()) as Box<Digest>)),
            arg @ _ => { println!(">>>Invalid option --sha{}", arg); return false; },
        }

        true
    }

    pub fn run_from_args() {
        let mut hash_sum = HashSum(Vec::new(), Vec::new(), FlagType::Print);

        for arg in cmd_args().skip(1) {
            if arg.starts_with("-") {
                match arg.as_ref() {
                    "--md5" => hash_sum.1.push(Checksum("MD5:".to_string(), Box::new(Md5::new()) as Box<Digest>)),
                    arg if arg.starts_with("--sha") => if !hash_sum.sha_match(&arg[5..]) { return usage(); },
                    "-o" | "--output" => hash_sum.2 = FlagType::Output,
                    "-c" | "--check" => hash_sum.2 = FlagType::Check,
                    "-p" | "--print" => hash_sum.2 = FlagType::Print,
                    arg @ _ => return invalid_usage(&format!(">>>Invalid option {}", arg)),
                }
            }
            else { hash_sum.0.push(arg) }
        }

        if hash_sum.0.len() == 0 {
            println!(">>>No input is given!");
            return;
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
                match self.2 {
                    FlagType::Output => {
                        let file_name = format!("{}.{}", &path, algo.get_file_ext());
                        if let Ok(mut file) = std::fs::File::create(&file_name) {
                            file.write_fmt(format_args!("{}\n", algo.get_checksum())).unwrap();
                            println!("{}{}", algo.get_type_string(), &file_name);
                        }
                        else {
                            println!("{}Unable to create file with checksum!", algo.get_type_string());
                        }
                    },
                    FlagType::Check => {
                        let file_name = format!("{}.{}", &path, algo.get_file_ext());
                        if let Ok(mut file) = std::fs::File::open(&file_name) {
                            let mut expected_checksum = String::new();
                            if file.read_to_string(&mut expected_checksum).is_ok() {
                                if expected_checksum.trim() == algo.get_checksum() {
                                    println!("{}OK", algo.get_type_string());
                                }
                                else {
                                    println!("{}NOT_OK", algo.get_type_string());
                                }
                            }
                            else {
                                println!("{}Failed to get checksum from file!", algo.get_type_string());
                            }
                        }
                        else {
                            println!("{}No checksum file!", algo.get_type_string());
                        }
                    },
                    FlagType::Print => {
                        println!("{}", algo.result());
                    },

                }
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
