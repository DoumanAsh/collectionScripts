
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

<#
    .Description
    Performs cleanup of all `target` folders for every crate
#>
function rust_clean_repos() {
    Param (
        [string]$folder,
        [switch]$h,
        [switch]$y,
        [switch]$help
    )

    if ($h -Or $help) {
        echo "Usage: rust_clean_repos [folder] [-y]"
        return
    }
    if ([string]::IsNullOrEmpty($folder)) {
        $folder = Get-Location
    }

    Get-ChildItem $folder -Recurse -Filter Cargo.toml -ErrorAction SilentlyContinue | Foreach-Object {
        $crate = Split-Path -Path "$($_.FullName)"
        $crate_target = Join-Path -Path "$crate" -ChildPath "target"

        if (Test-Path -Path $crate_target) {
            $title    = $crate_target
            $question = 'Are you sure you want to delete it?'
            $choices  = '&Yes', '&No'

            if ($y) {
                Remove-Item -Recurse -Force $crate_target
                echo "$($crate_target): Deleted..."
            } else {
                $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
                    if ($decision -eq 0) {
                        Remove-Item -Recurse -Force $crate_target
                        echo "Deleted"
                    }
            }
        }
    }
}
