extern crate winapi;
extern crate user32;

use user32::{EnumDisplaySettingsW, ChangeDisplaySettingsW};

use std::env::args as cmd_args;

#[inline(always)]
fn usage() {
println!("Usage: resolution_tool [command]

Commands:
    set [width] [height]         Change display settings.
    show                         Display current settings of display.

");
}

#[inline]
fn device_name(display_name: &[u16; winapi::winuser::CCHDEVICENAME]) -> String {
    let len: usize = display_name.iter().position(|&elem| elem == 0).unwrap_or(0);
    String::from_utf16_lossy(&display_name[..len])
}

#[inline]
fn enum_display_settings(dev_mode: &mut winapi::DEVMODEW) -> bool {
    let dev_mode_p: *mut winapi::DEVMODEW = dev_mode;
    unsafe { EnumDisplaySettingsW(std::ptr::null(), winapi::ENUM_CURRENT_SETTINGS, dev_mode_p) != 0 }
}

///Change display settings wrapper around ```ChangeDisplaySettingsW```
///
///# Return vale:
///
///* ```true``` if succesful or restart is required.
///* ```false``` Otherwise.
fn change_display_settings(dev_mode: &mut winapi::DEVMODEW) -> bool {
    let dev_mode_p: *mut winapi::DEVMODEW = dev_mode;
    unsafe {
        match ChangeDisplaySettingsW(dev_mode_p, winapi::CDS_UPDATEREGISTRY) {
            winapi::DISP_CHANGE_SUCCESSFUL => { println!(">>Succesfully set."); true },
            winapi::DISP_CHANGE_RESTART => { println!(">>To finish set reboot is required."); true },
            _ => { println!(">>Failed to set"); false },
        }
    }
}

///Set new display resolution.
fn display_set() {
    if cmd_args().len() < 4 {
        println!(">>set command requires width and height arguments");
        return usage();
    }

    let mut dev_mode: winapi::DEVMODEW = unsafe { std::mem::zeroed() };

    if enum_display_settings(&mut dev_mode) {
        let mut set_args = cmd_args().skip(2);
        let new_width: u32 = set_args.next().unwrap().parse().unwrap_or(0);
        let new_height: u32 = set_args.next().unwrap().parse().unwrap_or(0);

        if new_width == 0 || new_height == 0 {
            println!(">>Specified resolution settings are incorrect");
            return;
        }

        let name = device_name(&dev_mode.dmDeviceName);
        println!("Current Display {} settings:\nWidth={}\nHeight={}\n", &name, &dev_mode.dmPelsWidth, &dev_mode.dmPelsHeight);

        //Print warnings in case if the settings are not changed
        //Or abort if both are the same
        let is_same_width = new_width == dev_mode.dmPelsWidth;
        let is_same_height = new_height == dev_mode.dmPelsHeight;
        if is_same_width && is_same_height {
            println!(">>Specified resolution settings are the same. Nothing to do here.");
            return;
        }
        if is_same_width {
            println!(">>The width({}) is the same as original", new_width);
        }
        if is_same_height {
            println!(">>The height({}) is the same as original", new_height);
        }

        dev_mode.dmPelsWidth = new_width;
        dev_mode.dmPelsHeight = new_height;


        if change_display_settings(&mut dev_mode) {
            println!("New Display {} settings:\nWidth={}\nHeight={}", &name, &dev_mode.dmPelsWidth, &dev_mode.dmPelsHeight);
        }
    }
    else {
        println!("Failed to retrieve display settings");
    }
}

///Shows current display resolution.
fn display_show() {
    let mut dev_mode: winapi::DEVMODEW = unsafe { std::mem::zeroed() };

    if enum_display_settings(&mut dev_mode) {
        println!("Display {}:\nWidth={}\nHeight={}", device_name(&dev_mode.dmDeviceName), &dev_mode.dmPelsWidth, &dev_mode.dmPelsHeight);
    }
    else {
        println!("Failed to retrieve display settings");
    }
}

fn main() {
    if cmd_args().len() < 2 { return usage(); }

    match cmd_args().skip(1).next().unwrap().as_ref() {
        "set" => display_set(),
        "show" => display_show(),
        arg @ _ => {
            println!("Incorrect command {}", &arg);
            usage();
        }
    }
}
