extern crate windows_win;

use windows_win::*;

const GAME_ENGINE: &'static str = "ARCGameEngine";

fn hex_str_to_bytes(hex: &str) -> Vec<u8> {
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

fn main() {
    //0=Name, 1=Base, 2=Patch data, 3=Original data
    let games = [
        ("神採りアルケミーマイスター",         0x00411BD3, "3D 60 EA 00 00 EB 70 E8 89 67 14 00", "3d 60 EA 00 00 7E 70 E8 89 67 14 00"),
        ("創刻のアテリアル",                   0x00412003, "3D 60 EA 00 00 EB 70 E8 66 39 17 00", "3D 60 EA 00 00 7E 70 E8 66 39 17 00"),
        ("魔導巧殻 ～闇の月女神は導国で詠う～",0x00412153, "3D 60 EA 00 00 EB 70 E8 86 1D 1E 00", "3D 60 EA 00 00 7E 70 E8 86 1D 1E 00"),
        ("戦女神ZERO",                         0x0040B54A, "3D 60 EA 00 00 EB 64 E8 08 17 12 00", "3D 60 EA 00 00 7E 64 E8 08 17 12 00"),
        ("戦女神VERITA",                       0x0041219A, "3D 60 EA 00 00 EB 64 E8 55 07 14 00", "3D 60 EA 00 00 7E 64 E8 55 07 14 00"),
        ("姫狩りダンジョンマイスター",         0x004119CA, "3D 60 EA 00 00 EB 64 E8 0E F6 13 00", "3D 60 EA 00 00 7E 64 E8 0E F6 13 00"),
        ("天秤のLa DEA。 ～戦女神MEMORIA～",   0x004125C3, "3D 60 EA 00 00 EB 70 E8 A6 26 1E 00", "3D 60 EA 00 00 7E 70 E8 A6 26 1E 00"),
        ("神のラプソディ",                     0x00411D83, "3D 60 EA 00 00 EB 70 E8 36 2B 1E 00", "3D 60 EA 00 00 7E 70 E8 36 2B 1E 00"),
        ("珊海王の円環",                       0x00412203, "3D 60 EA 00 00 EB 70 E8 D6 44 1E 00", "3D 60 EA 00 00 7E 70 E8 D6 44 1E 00"),
    ];

    let running_games = get_windows_by_class(GAME_ENGINE, None).expect("Failed to look-up any games");

    if running_games.len() == 0 {
        return;
    }

    let games_to_patch = running_games.iter()
                                      .filter_map(|handle| {
                                          if let Some(data) = games.iter().find(|arr_elem| get_window_text(*handle).unwrap_or("".to_string()) == arr_elem.0) {
                                              return Some((*handle, data));
                                          }
                                          None
                                      });
    for (game_window, data) in games_to_patch {
        println!("Detected game: {}", data.0);
        let patch_data = hex_str_to_bytes(data.2);
        let orig_data = hex_str_to_bytes(data.3);

        let (pid, _) = get_windows_thread_process_id(game_window);

        match open_process(pid, 0x0038) {
            Ok(handle) => {
                let process_data = read_process_memory(handle, data.1, orig_data.len()).expect("Failed to read memory");

                if process_data == patch_data {
                    println!("Already has been patched");
                }
                else if process_data == orig_data {
                    println!("Apply patch...");
                    match write_process_memory(handle, data.1, &patch_data) {
                        Ok(_) => println!("Done!"),
                        Err(error) => println!("Failed. Reason={}", error.errno_desc()),
                    }
                }
                else {
                    println!("Unexpected data: {}", process_data.iter().fold(String::new(), |acc, &elem| acc + &format!("{:x} ", elem)));
                }

                close_process(handle).expect("Failed to close process");;
            },
            Err(error) => {
                println!("Unable to open its process. Error={}", error.errno_desc());
            },
        }

        println!("-------------------------\n");
    }
}
