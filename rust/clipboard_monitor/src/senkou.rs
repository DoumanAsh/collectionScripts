//! Senkou text splitter
//!
//! Just split text by half(VNR captures double text)

extern crate clipboard_win;
use clipboard_win::{set_clipboard, ClipboardManager};

fn handler_clip_text(text: &String) {
    let len = text.len();
    if len == 0 || len % 2 == 1 { return; }

    const BEGIN: &'static[char] = &['「', '（'];
    const END: &'static[char] = &['」', '）'];
    if let (Some(begin_pos), Some(end_pos)) = (text.rfind(BEGIN), text.rfind(END)) {
        println!(">>>Action:");
        //+3 to skip begin symbol
        if set_clipboard(&text[begin_pos+3..end_pos]).is_err() {
            println!("Failed to update clipboard");
        }

        println!("Dialogue is extracted");
    }
    else {
        let chars: Vec<char> = text.chars().collect();
        if !chars.starts_with(&chars[chars.len()/2..]) { return; }

        drop(chars);
        println!(">>>Action:");
        if set_clipboard(&text[..len/2]).is_err() {
            println!("Failed to update clipboard");
        }

        println!("String repetition is removed(string is halved).");
    }
}

fn main() {
    println!("####################################");
    println!("#  Senkou Text repetition remover  #");
    println!("####################################");
    ClipboardManager::new().delay(1).ok_callback(handler_clip_text).run();
}
