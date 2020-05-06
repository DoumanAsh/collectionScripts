# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

$env:LANG="en_US.utf8"

$CollectionDir = "$PSScriptRoot"

if (Test-Path($CollectionDir)) {
    . "$CollectionDir\set_compiler.ps1"
    . "$CollectionDir\linux_ps.ps1"
    . "$CollectionDir\vcpkg.ps1"
    . "$CollectionDir\clang_utils.ps1"
    . "$CollectionDir\rust_utils.ps1"
    . "$CollectionDir\cmake.ps1"
    . "$CollectionDir\prompt.ps1"
    . "$CollectionDir\vcvars_env.ps1"

    $env:RUSTUP_TOOLCHAIN = "$(rust_get_default_channel)"
}

Import-Module PSReadLine
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineOption -BellStyle Visual

Set-PSReadlineOption -Color @{
    "Command" = [ConsoleColor]::Green
    "Parameter" = [ConsoleColor]::Gray
    "Operator" = [ConsoleColor]::Magenta
    "Variable" = [ConsoleColor]::White
    "String" = [ConsoleColor]::Yellow
    "Number" = [ConsoleColor]::Blue
    "Type" = [ConsoleColor]::Cyan
    "Comment" = [ConsoleColor]::DarkCyan
}

function unzip() {
    foreach ($arg in $args) {
        7z x "$arg"
    }
}

function grep {
    $count = @($input).Count
    $input.Reset()

    if ($count) {
        $input | rg.exe --hidden $args
    } else {
        rg.exe --hidden $args
    }
}

set_vc "amd64"

if (Get-Command "clang-cl" -ErrorAction SilentlyContinue) {
    set_cc clang-cl
} elseif (Get-Command "cl" -ErrorAction SilentlyContinue) {
    set_cc cl
}

## Aliases
if (Get-Command "lua53.exe" -ErrorAction SilentlyContinue) {
    Set-Alias lua lua53.exe
}

if (Get-Command "nvim-qt.exe" -ErrorAction SilentlyContinue) {
    Set-Alias gvim nvim-qt.exe
}
