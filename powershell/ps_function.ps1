function prompt { "[$($executionContext.SessionState.Path.CurrentLocation)]$("`n>" * ($nestedPromptLevel + 1)) " }
function which($name){Get-Command $name | Select-Object -ExpandProperty Definition}
function readlink($name) {Get-Item $name | select -ExpandProperty FullName }
function pwd {Get-Location | select -ExpandProperty Path}
function gitk {wish $(Join-Path $(Split-Path $(which git)) gitk) }
function cxfreeze {python E:\Soft\Misc\chocolatey\bin\python\Scripts\cxfreeze $args}
function ctags_rust {ctags --options=E:\Soft\Develop\Rust\etc\ctags.rust $args}

function Get-ClipboardText()
{
	Add-Type -AssemblyName System.Windows.Forms
	$tb = New-Object System.Windows.Forms.TextBox
	$tb.Multiline = $true
	$tb.Paste()
	$tb.Text
}
