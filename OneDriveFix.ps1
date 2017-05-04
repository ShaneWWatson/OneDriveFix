<#
Script written by Eric Riggan
Edited by Shane Watson
#>

$DebugPreference = "Inquire"
$ErrorActionPreference = "Inquire"

# Initialize variables
$item = ""
$rawName = ""
$extension = ""
$newName = ""
$progress = 0

Write-Host "This utility will recursively scan for and delete illegal characters"
Write-Host "in filenames, and create a log of filenames with characters over 245 "
Write-Host "characters."
Write-Host ""
Write-Host "The log will be saved to $PSScriptRoot\log.txt"
Write-Host ""
$boundUpper = 245 #This can be changed to anything reasonable.
Clear-Host
out-file $PSScriptRoot\log.txt #Intialize Log File
$count = (Get-ChildItem -Recurse -Depth 20).count #Get number of files. Use Depth to prevent issues with deep dir trees.
Write-Host $count files to analyze.
$progress = 0 #Initialize counter.
try {
    foreach ($item in Get-ChildItem -recurse | Sort-Object FullName -desc | select-Object -ExpandProperty FullName) {
        $rawName = $item
        $extension = split-path $rawName -Leaf
        if ($extension -ne "OneDriveFix.ps1") {
            $newName = $extension -replace "`#`~`"`%`:`>`?`&`{`}`|", ''
            $newName = $newName.Trim()
            if ($extension -ne $newName) {
                if ($extension.Substring(0, 1) -eq " ") {
                    Move-Item -LiteralPath $rawName -Destination $newName
                }
                else {
                    rename-item -Path $rawName -newName $newName -ErrorAction Stop -ErrorVariable Bork
                }
            }
            $progress = $progress + 1
            Clear-Host
            Write-Host $progress of $count renamed...
        }
    }
}
catch {   
    $BorkMsg = $_.Exception.Message
    $BorkItem = $_.Exception.Itemname
    Write-Host "FAILED! $BorkMsg $BorkItem"
    Break
}
finally {
}
Clear-Host #This section checks for filename sizes larger than the value of $boundUpper
$progress = 0
try {
    foreach ($item in Get-ChildItem -recurse | Sort-Object FullName -desc | select-Object -ExpandProperty FullName) {
        $longName = $item
        $shortName = $longName.replace($PSScriptRoot, "")
        $measureObject = $shortName | Measure-Object -character
        $charCount = $measureObject.Characters
        IF ($charCount -gt $boundUpper) {
            $longName | Add-Content $PSScriptRoot\log.txt
        }
        $progress = $progress + 1
        Clear-Host
        Write-Host $progress of $count filenames analyzed...
    }
}
catch {
    Write-Host "FAILED!"
}
finally {
    Write-Host "FAILED!"
}
Clear-Host