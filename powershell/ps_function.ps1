function prompt { "[$($executionContext.SessionState.Path.CurrentLocation)]$("`n>" * ($nestedPromptLevel + 1)) " }
function which($name){Get-Command $name | Select-Object -ExpandProperty Definition}
function readlink($name) {Get-Item $name | select -ExpandProperty FullName }
function pwd {Get-Location | select -ExpandProperty Path}
