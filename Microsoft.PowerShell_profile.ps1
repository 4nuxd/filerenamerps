function RenameFiles {
    param (
        [string]$directory = ".",
        [switch]$RemoveSpaces,
        [switch]$RemoveUnderscores,
        [switch]$RemoveSpecialChars,
        [string]$Prefix,
        [switch]$RemoveFirstUnderscore
    )

    Set-Location -Path $directory
    $scriptPath = "C:\Users\Anurag\Documents\WindowsPowerShell\noob.ps1"
    & $scriptPath -folderPath $directory `
                  -removeSpaces:$RemoveSpaces `
                  -removeUnderscores:$RemoveUnderscores `
                  -removeSpecialChars:$RemoveSpecialChars `
                  -prefix $Prefix `
                  -removeFirstUnderscore:$RemoveFirstUnderscore
}

function RenameFilesGUI {
    param (
        [string]$directory = ".",
        [switch]$RemoveSpaces,
        [switch]$RemoveUnderscores,
        [switch]$RemoveSpecialChars,
        [string]$Prefix,
        [switch]$RemoveFirstUnderscore
    )

    Set-Location -Path $directory
    $scriptPath = "C:\Users\Anurag\Documents\WindowsPowerShell\noob_gui.ps1"
    & $scriptPath -folderPath $directory `
                  -removeSpaces:$RemoveSpaces `
                  -removeUnderscores:$RemoveUnderscores `
                  -removeSpecialChars:$RemoveSpecialChars `
                  -prefix $Prefix `
                  -removeFirstUnderscore:$RemoveFirstUnderscore
}

Set-Alias -Name rf -Value RenameFiles
Set-Alias -Name rfg -Value RenameFilesGUI
