# Provides linux like aliases

Remove-Item -ErrorAction SilentlyContinue alias:\cd
Remove-Item -ErrorAction SilentlyContinue alias:\pwd
Remove-Item -ErrorAction SilentlyContinue alias:\which
Remove-Item -ErrorAction SilentlyContinue alias:\pwd

#get only definition
function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}
#unix like readlink. Gets only full path
function readlink($name) {
    Get-Item $name | select -ExpandProperty FullName
}
#unix like pwd.
function pwd {
    Get-Location | select -ExpandProperty Path
}

$global:OLDPWD = Get-Location | select -ExpandProperty Path

function cd([string]$path) {
    $old = $global:OLDPWD
    $global:OLDPWD = Get-Location | select -ExpandProperty Path

    Switch ($path) {
        "-" {
            Set-Location $old
        }
        "" {
            Set-Location ~
        }
        default {
            try {
                Set-Location $path
            }
            catch {
                $global:OLDPWD = $old
                throw
            }
        }
    }

}
