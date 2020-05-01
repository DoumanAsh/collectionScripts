extern crate hoedown;
use hoedown::renderer::Render;

use std::env::args as cmd_args;
use std::io::{Read, Write, BufReader};

const USAGE: &'static str  = "Usage: md_render <files>... [options]

Options:
--css=<file_name> - specify name of css file to link with.
--inline-css=<file_name> - specify the name of css file which style will be inlined.
--toc=<num> - specify the level of deepness for table of contents. Default 0.
";

const EXT_TABLES: u32            = 1 << 0;
const EXT_FENCED_CODE: u32       = 1 << 1;
const EXT_FOOTNOTES: u32         = 1 << 2;
const EXT_AUTOLINK: u32          = 1 << 3;
const EXT_STRIKETHROUGH: u32     = 1 << 4;
const EXT_UNDERLINE: u32         = 1 << 5;
const EXT_HIGHLIGHT: u32         = 1 << 6;
const EXT_QUOTE: u32             = 1 << 7;
const EXT_NO_INTRA_EMPHASIS: u32 = 1 << 11;
const EXT_SPACE_HEADERS: u32     = 1 << 12;

macro_rules! is_file {
    ($path:expr) => { std::fs::metadata($path).unwrap().is_file() }
}

#[inline]
fn usage() {
    println!("{}", USAGE);
}

fn main() {
    if cmd_args().len() < 2 { return usage(); }

    let mut toc: i32 = 0;
    let mut css = String::new();
    let mut md_files: Vec<String> = vec![];
    for arg in cmd_args().skip(1) {
        if arg.starts_with("--") {
            let arg = &arg[2..];
            let eq_pos = arg.find('=');

            if arg.starts_with("css") {
                if let Some(eq_pos) = eq_pos {
                    std::fmt::Write::write_fmt(&mut css,
                                               format_args!("<link rel=\"stylesheet\" href=\"{}\">\n", &arg[eq_pos+1..])).unwrap();
                }
                else {
                    println!(">>>Invalid use of options. CSS File is not specified!");
                }

            }
            else if arg.starts_with("toc") {
                if let Some(eq_pos) = eq_pos {
                    if let Ok(eq_pos) = arg[eq_pos+1..].parse::<i32>() {
                        toc = eq_pos;
                    }
                    else {
                        println!(">>>Invalid use of options. ToC number is invalid!");
                    }
                }
                else {
                    println!(">>>Invalid use of options. ToC number is not specified!");
                }
            }
            else if arg.starts_with("inline-css") {
                if let Some(eq_pos) = eq_pos {
                    if let Ok(mut css_file) = std::fs::File::open(&arg[eq_pos+1..]) {
                        css.push_str("<style>\n");
                        css_file.read_to_string(&mut css).unwrap();
                        css.push_str("</style>\n");
                    }
                    else {
                        println!(">>>{}: no such CSS", &arg[eq_pos+1..]);
                    }
                }
                else {
                    println!(">>>Invalid use of options. CSS File is not specified!");
                }
            }
        }
        else if is_file!(&arg) {
            md_files.push(arg);
        }
        else {
            println!(">>>{}: No such file!\n", arg);
        }
    };

    if md_files.len() == 0 {
        println!(">>>No Markdown files are  specified!\n");
        usage();
        return;
    }

    let md_ext = hoedown::Extension::from_bits_truncate(EXT_TABLES |
                                                        EXT_FENCED_CODE |
                                                        EXT_FOOTNOTES |
                                                        EXT_AUTOLINK |
                                                        EXT_STRIKETHROUGH |
                                                        EXT_UNDERLINE |
                                                        EXT_HIGHLIGHT |
                                                        EXT_QUOTE |
                                                        EXT_NO_INTRA_EMPHASIS |
                                                        EXT_SPACE_HEADERS);
    let flags = hoedown::renderer::html::Flags::empty();
    let mut html_render = hoedown::renderer::html::Html::new(flags, toc);
    let mut html_toc = hoedown::renderer::html::Html::toc(toc);
    for arg in md_files {
        println!("Render - {}", &arg);
        let html_path = std::path::Path::new(&arg).with_extension("html");

        if let Ok(file) = std::fs::File::open(&arg) {
            let mut html_file = std::fs::File::create(&html_path).unwrap();

            let file = BufReader::new(file);
            let file = hoedown::Markdown::read_from(file).extensions(md_ext);
            let render_result = html_render.render(&file);

            html_file.write_all(css.as_bytes()).unwrap();
            if toc > 0 {
                let render_toc = html_toc.render(&file);
                html_file.write_all(b"<h1>Table of Content</h1>").unwrap();
                html_file.write_all(&render_toc).unwrap();
            }
            html_file.write_all(&render_result).unwrap();
            println!(">>>Result: {}", &html_path.to_str().unwrap_or(""));
        }
        else {
            println!(">>>{}: failed to open", &arg);
        }
        println!("");
    }
}
