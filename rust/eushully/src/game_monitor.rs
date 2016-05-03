extern crate lazy_bytes_cast;

use std::mem;
use self::lazy_bytes_cast::{
    ToBytesCast,
    FromBytesCast
};

extern crate windows_win;

use windows_win::*;
extern crate winapi;
use self::winapi::winnt::HANDLE;

pub struct GameMonitor {
    base: u32,
    process: HANDLE
}

impl GameMonitor {
    ///Constructs game monitor
    pub fn new(game_name: &str, base_addr: u32) -> Option<GameMonitor>  {
        let running_games = get_windows_by_class(GAME_ENGINE, None).expect("Failed to look-up any games");

        if running_games.len() == 0 {
            println!("No running Eushully game");
            return None;
        }

        let running_games = running_games.iter()
                                         .filter(|handle| {
                                             if let Ok(run_name) = get_window_text(**handle) {
                                                 return run_name == game_name;
                                             }
                                             false
        }).collect::<Vec<_>>();

        if running_games.len() == 0 {
            println!("Cannot find {}", game_name);
            return None;
        }
        else if running_games.len() > 1 {
            println!("Too many running games");
            return None;
        }

        let (pid, _) = get_windows_thread_process_id(*running_games[0]);
        match open_process(pid, 0x0038) {
            Ok(process_handle) => Some(GameMonitor {base: base_addr, process: process_handle}),
            Err(_) => None,
        }
    }

    #[inline]
    pub fn read_mem(&self, position: u32, size: usize) -> Vec<u8> {
        return read_process_memory(self.process, position, size).expect("Failed to read game's memory");
    }

    #[inline]
    pub fn write_mem(&self, position: u32, data: &[u8]) {
        return write_process_memory(self.process, position, data).expect("Failed to write game's memory");
    }

    ///Reads integers from process's memory
    pub fn read<T: ToBytesCast>(&self, position: u32) -> T {
        self.read_mem(position, mem::size_of::<T>()).cast_to().unwrap()
    }

    ///Writes integers into process's memory
    pub fn write<T: ToBytesCast>(&self, position: u32, data: T) {
        self.write_mem(position, &data.to_bytes());
    }
}
