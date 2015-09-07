#Clean-up crates
$old_location = $pwd

Get-ChildItem $PSScriptRoot |
?{ $_.PSIsContainer } |
foreach  { echo (">>>{0}: clean" -f $_.FullName);
           set-location $_.FullName;
           cargo clean;
        }

set-location $old_location;
