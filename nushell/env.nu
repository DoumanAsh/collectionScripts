# Nushell Environment Config File
#
# version = "0.90.1"

$env.LANG = "en_US.UTF-8"
$env.LC_ALL = "en_US.UTF-8"
$env.LC_CTYPE = "en_US.UTF-8"
$env._OS = (sys host | get name);


const env_root = path self .
use $"($env_root)/scripts/prompt.nu" git_prompt
use $"($env_root)/scripts/cmake.nu" *
use $"($env_root)/scripts/rust.nu" *
use $"($env_root)/scripts/utils.nu" *

$env.PROMPT_COMMAND = { || git_prompt }
$env.PROMPT_COMMAND_RIGHT = ""

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = {|| "$ " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| "$ " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

if ($env._OS == Windows) {
    use $"($env_root)/scripts/msvc.nu" set_vc_env_from_bat

    $env.HOME = $"($env.SystemDrive)($env.HOMEPATH)"
    $env._PATH = "Path"

    set_vc_env_from_bat "amd64"
    if (not (which clang-cl | is-empty)) {
        set_cc clang-cl
    } else if (not (which clang-cl | is-empty)) {
        set_cc cl
    }
} else {
    $env._PATH = "PATH"
    if (not (which clang | is-empty)) {
        set_cc clang
    }
}

# env.Path mods
env_add_path ...[
    ($env.HOME | path join .cargo | path join bin)
    ($env.HOME | path join soft | path join tools)
    ($env.HOME | path join soft | path join google-cloud-sdk | path join bin)
    ($env.HOME | path join .local | path join share | path join coursier | path join bin)
    "/usr/local/bin"
    "/opt/personal"
    "/opt/podman/bin"
    "/opt/nvim/bin"
    "/opt/lua-language-server/bin"
]

if ($env._OS == "Darwin") {
    env_add_path ...[
        "/opt/homebrew/bin"
        ("/Users" | path join ($env.USER) "Library" "Android" "sdk" "platform-tools")
    ]
}

# Cmake
$env.CMAKE_EXPORT_COMPILE_COMMANDS = "ON"

# Make sure default toolchain is always specified via env var
$env.RUSTUP_TOOLCHAIN = (rust_get_default_channel)

# Editor
if (which nvim | is-not-empty) {
    $env.EDITOR = "nvim"
} else if (which vim | is-not-empty) {
    $env.EDITOR = "vim"
}

# Java
if (which java | is-not-empty) {
    $env.JAVA_HOME = $"(which java | get path | path expand | path dirname -n 2 | get 0)"
}

# Conditionally select graphical vim since you cannot export alias in if block
def gvim [...rest] {
    if (which neovide | is-not-empty) {
        neovide ...$rest
    } else if (which nvim-qt | is-not-empty) {
        with-env { "NVIM_QT": "1" } {
            nvim-qt ...$rest
        }
    }
}


if (which fastfetch | is-not-empty) {
    clear
    fastfetch --logo-type kitty-direct --logo $"($env_root)/PRTS-ai.png" -C $"($env_root)/fastfetch.jsonc"
} else {

print "##################
# Initialize shell
###################
"
print $"System: (sys host | get long_os_version)"
print $"Memory: (sys mem | get available | into string | split row -r '\s+' | get 0)/(sys mem | get total)"
print $"Uptime: (sys host | get uptime)"


print "
###########################"
}
