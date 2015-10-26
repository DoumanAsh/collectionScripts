//! Text utils

#[inline(always)]
pub fn is_jp<T: AsRef<str>>(text: T) -> bool {
    let text = text.as_ref();
    text.chars().any(|elem_char| match elem_char { '\u{3000}'...'\u{303f}'| //punctuation
                                                   '\u{3040}'...'\u{309f}'| //hiragana
                                                   '\u{30a0}'...'\u{30ff}'| //katakana
                                                   '\u{ff00}'...'\u{ffef}'| //roman characters
                                                   '\u{4e00}'...'\u{9faf}'| //common kanji
                                                   '\u{3400}'...'\u{4dbf}'  //rare kanji
                                                      => true,
                                                   _  => false,
    })
}

pub fn remove_text_reps(text: &str) -> String {
    let mut text = &text[..];
    loop {
        let chars: Vec<char> = text.chars().collect();
        if !chars.starts_with(&chars[chars.len()/2..]) { break; }

        text = &text[..text.len()/2];
    }

    text.to_string()
}
