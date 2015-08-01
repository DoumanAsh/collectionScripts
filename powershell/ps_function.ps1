function prompt { "[$($executionContext.SessionState.Path.CurrentLocation)]$("`n>" * ($nestedPromptLevel + 1)) " }
function which($name){Get-Command $name | Select-Object -ExpandProperty Definition}
function readlink($name) {Get-Item $name | select -ExpandProperty FullName }
function pwd {Get-Location | select -ExpandProperty Path}
function gitk {wish $(Join-Path $(Split-Path $(which git)) gitk) }
function cxfreeze {python E:\Soft\Misc\chocolatey\bin\python\Scripts\cxfreeze $args}
function ctags_rust {ctags --options=E:\Soft\Develop\Rust\etc\ctags.rust $args}
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

function Get-ClipboardText()
{
	Add-Type -AssemblyName System.Windows.Forms
	$tb = New-Object System.Windows.Forms.TextBox
	$tb.Multiline = $true
	$tb.Paste()
	$tb.Text
}
