# Provides linux like aliases

Remove-Item -ErrorAction SilentlyContinue alias:\cd
Remove-Item -ErrorAction SilentlyContinue alias:\pwd
Remove-Item -ErrorAction SilentlyContinue alias:\which
Remove-Item -ErrorAction SilentlyContinue alias:\pwd

#get only definition
function which($name) {
    try {
        Get-Command $name -ErrorAction Stop | Select-Object -ExpandProperty Definition
    } catch [System.Management.Automation.CommandNotFoundException] {
    }
}
#unix like readlink. Gets only full path
function readlink($name) {
    try {
        Get-Item $name -ErrorAction Stop | select -ExpandProperty FullName
    } catch [System.Management.Automation.ItemNotFoundException] {
    }
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
            $res = Set-Location $path -ErrorAction Ignore -PassThru

            if (!$res) {
                $global:OLDPWD = $old
                echo "$($path): No such file or directory"
            }
        }
    }

}
