//! VN text corrector

extern crate clipboard_win;
use clipboard_win::{set_clipboard};
mod utils;
mod manager;
mod alpha_ride;
mod evolimit;
mod genrin2;
mod izumo;
mod senkou;

use std::env::args as cmd_args;

const USAGE: &'static str = "Usage: vn_text_corrector <type>

Types:
    alpha_ride
    evolimit
    genrin2
    izumo
    senkou
    vn          - default.
";

fn handler_clip_text(text: &String) {
    if !utils::is_jp(text) { return; }

    const BEGIN: &'static[char] = &['「', '（'];
    const END: &'static[char] = &['」', '）'];
    if let (Some(begin_pos), Some(end_pos)) = (text.find(BEGIN), text.find(END)) {
        let end_pos = end_pos + 3; //+3 to go at the symbol of dialogue end
        if end_pos == text.len() { return; }

        println!(">>>Action:");
        if set_clipboard(&text[begin_pos..end_pos].replace("\n", "")).is_err() {
            println!("Hmph... failed to update clipboard");
        }
        else {
            println!("Dialogue is extracted");
        }
    }
}

fn main() {
    let handler: fn(&String) = match cmd_args().skip(1)
                                               .next()
                                               .as_ref()
                                               .map(|s| &**s) {
        None => handler_clip_text,
        Some("alpha_ride") => alpha_ride::handler_clip_text,
        Some("senkou") => senkou::handler_clip_text,
        Some("izumo") => izumo::handler_clip_text,
        Some("genrin2") => genrin2::handler_clip_text,
        Some("evolimit") => evolimit::handler_clip_text,
        Some("-h") | Some("--help") => {
            println!("{}", USAGE);
            return;
        }
        arg @ _ => {
            println!("Incorrect argument: {}", arg.unwrap());
            println!("{}", USAGE);
            return;
        }
    };

    println!("Start text corrector\n");

    manager::ClipboardManager::new().delay(10)
                                    .ok_callback(handler)
                                    .run();
}
