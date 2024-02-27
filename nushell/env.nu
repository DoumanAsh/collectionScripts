# Nushell Environment Config File
#
# version = "0.90.1"

echo "##################
# Initialize shell
###################
"

$env.LANG = "en_US.utf8"
$env._OS = (sys | get host | get name);

echo $"System: ($env._OS)"

const root = ($nu.env-path | path dirname)
use $"($root)/scripts/prompt.nu" git_prompt
use $"($root)/scripts/msvc.nu" set_vc_env_from_bat
use $"($root)/scripts/cmake.nu" *
use $"($root)/scripts/utils.nu" *

$env.PROMPT_COMMAND = { || git_prompt }
$env.PROMPT_COMMAND_RIGHT = ""

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = {|| "$ " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
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

# Directories to search for scripts when calling source or use
# The default for this is $nu.default-config-dir/scripts
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
]

# Directories to search for plugin binaries when calling register
# The default for this is $nu.default-config-dir/plugins
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

if ($env._OS == Windows) {
    $env.HOME = $"($env.SystemDrive)($env.HOMEPATH)"
    $env._PATH = "Path"

    set_vc_env_from_bat "amd64"
    if (not (which clang-cl | is-empty)) {
        set_cc clang-cl
    } else {
        set_cc cl
    }
} else {
    $env._PATH = "PATH"
    if (not (which clang | is-empty)) {
        set_cc clang
    }
}

# env.Path mods
env_add_path ($env.HOME | path join .cargo | path join bin)
env_add_path ($env.HOME | path join soft | path join tools)
env_add_path ($env.HOME | path join soft | path join google-cloud-sdk | path join bin)
env_add_path "/opt/homebrew/bin"

# Aliases
export alias gvim = nvim-qt

echo "
###########################"
