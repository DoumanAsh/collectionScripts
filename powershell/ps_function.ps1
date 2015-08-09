function prompt { "[$($executionContext.SessionState.Path.CurrentLocation)]$("`n>" * ($nestedPromptLevel + 1)) " }
#get only definition
function which($name){Get-Command $name | Select-Object -ExpandProperty Definition}
#unix like readlink. Gets only full path
function readlink($name) {Get-Item $name | select -ExpandProperty FullName }
#unix like pwd.
function pwd {Get-Location | select -ExpandProperty Path}
#utils shortcuts
function gitk {wish $(Join-Path $(Split-Path $(which git)) gitk) }
function cxfreeze {python $(Join-Path $(Split-Path $(which python)) "Scripts\cxfreeze") $args}
function ctags_rust {ctags --options="$(Join-Path $(Split-Path $(which rustc)) "etc\ctags.rust")" $args}
#usage: ". set_alias <name, value[, scope]>..
#separator is whie-space
function set_alias() {
    foreach ($arg in $args) {
        $params = $arg.split(",")
        $name = $arg[0]
        $value = $arg[1]
        if ($parmas.Length -lt 3) {
            $scope = "AllScope"
        }
        else {
            $scope = $arg[2]
        }
        New-Alias -Name "$name" -Value $value -Option "$scope" -Force
    }
}

function unzip() {
    foreach ($arg in $args) {
        if (Test-Path "$arg") {
            7z x "$arg"
        }
        else {
            echo (">>>{0}: no such file" -f $arg)
        }
    }
}

function unpack_msi() {
    foreach ($arg in $args) {
        if (Test-Path "$arg") {
            $msi_dir = Split-Path "$arg"
            $basename = (Get-Item "$arg").Basename
            $result_dir = (Join-Path $msi_dir $basename)
            if (-Not (Test-Path "$result_dir")) {
                mkdir $result_dir
            }
            msiexec /a "$arg" TARGETDIR="$result_dir" /qn
            echo (">>>{0} extracted into -> {1}" -f $arg,$result_dir)
        }
        else {
            echo (">>>{0}: no such file" -f $arg)
        }
    }
}

function Get-ClipboardText()
{
	Add-Type -AssemblyName System.Windows.Forms
	$tb = New-Object System.Windows.Forms.TextBox
	$tb.Multiline = $true
	$tb.Paste()
	$tb.Text
}
