//! Evolimit VN text corrector.

extern crate clipboard_win;
use clipboard_win::{set_clipboard};
use utils;

pub fn handler_clip_text(text: &String) {
    if !utils::is_jp(&text) { return; }

    let mut update = false;
    let mut text = text.clone();

    const DOT: &'static str = "・";
    if let Some(_) = text.find(DOT) {
        update = true;
        text = text.replace(DOT, "");
    }

    if update {
        println!(">>>Action:");
        if set_clipboard(&text).is_err() {
            println!("Hmph... failed to update clipboard");
        }
        else {
            println!("Text is cleaned");
        }
    }
}
