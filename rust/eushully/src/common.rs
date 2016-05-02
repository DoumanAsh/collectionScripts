pub const GAME_ENGINE: &'static str = "ARCGameEngine";

pub fn hex_str_to_bytes(hex: &str) -> Vec<u8> {
    let mut result = Vec::new();
    let mut modulus = 0;
    let mut buf = 0;

    for (idx, byte) in hex.replace(" ", "").bytes().enumerate() {
        buf <<= 4;

        match byte {
            b'A'...b'F' => buf |= byte - b'A' + 10,
            b'a'...b'f' => buf |= byte - b'a' + 10,
            b'0'...b'9' => buf |= byte - b'0',
            b' '|b'\r'|b'\n'|b'\t' => {
                buf >>= 4;
                continue
            },
            _ => {
                let ch = hex[idx..].chars().next().unwrap();
                panic!(format!("Invalid character={}", ch));
            }
        }

        modulus += 1;
        if modulus == 2 {
            modulus = 0;
            result.push(buf);
        }
    }

    result
}
