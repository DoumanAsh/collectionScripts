//! Senkou text splitter
//!
//! Just split text by half(VNR captures double text)

extern crate clipboard_win;
use clipboard_win::{set_clipboard, ClipboardManager};

fn handler_clip_text(text: &String) {
    let len = text.len();
    let len_half = len / 2;
    if len == 0 || len % 2 == 1 { return; }

    let chars: Vec<char> = text.chars().collect();
    if !chars.starts_with(&chars[chars.len()/2..]) { return; }

    drop(chars);
    println!(">>>Action:");
    if set_clipboard(&text[..len_half]).is_err() {
        println!("Failed to update clipboard");
    }

    println!("String repetition is removed(string is halved).");
}

fn main() {
    println!("####################################");
    println!("#  Senkou Text repetition remover  #");
    println!("####################################");
    ClipboardManager::new().delay(10).ok_callback(handler_clip_text).run();
}
