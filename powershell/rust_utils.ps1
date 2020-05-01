
<#
    Retrieves default toolchain from rustup
#>
function rust_get_default_channel() {
    if (Get-Command "rustup" -ErrorAction SilentlyContinue) {
        $default = rustup default | Select-String -Pattern "([^ ]+)+ \(default\)"
        $default = $default.matches.groups[1]

        echo "$default"
    } else {
        echo ""
    }
}
