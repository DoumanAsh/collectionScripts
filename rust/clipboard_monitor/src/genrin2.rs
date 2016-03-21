//! Genrin 2 text corrector.

extern crate clipboard_win;
use clipboard_win::{set_clipboard};
use utils;

pub fn handler_clip_text(text: &String) {
    if !utils::is_jp(text) { return; }

    const WHITE_SPACE: char = '　';

    if text.starts_with("[") {
        return;
    }

    if let Some(pos) = text.find(WHITE_SPACE) {
        println!(">>>Action:");
        let (name, text) = text.split_at(pos);
        if set_clipboard(&format!("[{}]{}", name, text)).is_err() {
            println!("Hmph... failed to update clipboard");
        }
        else {
            println!("Name has been wrapped");
        }
    }
}
