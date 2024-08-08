function Remove-ExtraUnderscores {
    param (
        [string]$filename
    )
    $filenameParts = $filename -split '_'
    if ($filenameParts.Count -gt 1) {
        return "$($filenameParts[0])_$($filenameParts[1..($filenameParts.Count - 1)] -join '')"
    } else {
        return $filename
    }
}

function Remove-UnwantedCharacters {
    param (
        [string]$filename,
        [string]$preserveChars
    )
    $pattern = "[^a-zA-Z0-9_$preserveChars]"
    return -join ($filename -replace $pattern, '')
}

function Update-UserActivity {
    param (
        [string]$username,
        [string]$activity,
        [string]$folder
    )
    $activityFilePath = "$env:USERPROFILE\last_user_activity.txt"
    try {
        Set-Content -Path $activityFilePath -Value @"
  Last User: $username
  Last Activity: $activity
  Last Folder Renamed: $folder
"@
        Write-Log -message "Updated user activity: User=$username, Activity=$activity, Folder=$folder"
    } catch {
        Write-Host "Error updating user activity: $_" -ForegroundColor Red
        Write-Log -message "Error updating user activity: $_" -isError $true
    }
}

function Display-UserActivity {
    $activityFilePath = "$env:USERPROFILE\last_user_activity.txt"
    if (Test-Path -Path $activityFilePath) {
        Get-Content -Path $activityFilePath
    } else {
        @"
  Last User: N/A
  Last Activity: N/A
  Last Folder Renamed: N/A
"@
    }
}

function Write-Log {
    param (
        [string]$message,
        [bool]$isError = $false
    )
    $logFilePath = "$env:USERPROFILE\file_renamer.log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entryType = if ($isError) { "ERROR" } else { "INFO" }
    $logEntry = "$timestamp [$entryType] $message"
    Add-Content -Path $logFilePath -Value $logEntry
}

$banner = @"
     __________     ____                                     
    / ___/ ___/    / __ \___  ____  ____ _____ ___  ___  _____
    \__ \\__ \    / /_/ / _ \/ __ \/ __ \/ __ \__ \/ _ \/ ___/
   ___/ /__/ /   / _, _/  __/ / / / /_/ / / / / / /  __/ /   
  /____/____/   /_/ |_|\___/_/ /_/\__,_/_/ /_/ /_/\___/_/
===========================================================================
  Description : A Simple File Renamer                                    
  Current Version : v0.0.1 [ Stable ]                                   
  Author : Who knows where curiosity leads Us                            
============================================================================
"@
Write-Host $banner -ForegroundColor White
Write-Log -message "Script started"
function Show-BannerAndMenu {
    Clear-Host
    Write-Host $banner -ForegroundColor White
    Write-Log -message "Banner displayed"

    Display-UserActivity

    Write-Host "============================================================================"
    Write-Host
    Write-Host "  Choose an option To Perform:"
    Write-Host
    Write-Host "  1. Remove underscores (except the first one)"
    Write-Host "  2. Remove spaces"
    Write-Host "  3. Remove unwanted special characters"
    Write-Host "  4. Add prefix to filenames"
    Write-Host "  5. Remove the first underscore"
    Write-Host "  6. Replace a word in filenames"
    Write-Host "  7. Exit"
    Write-Host
    Write-Host "============================================================================"
    Write-Host
}

	function Get-ValidFolderPath {
    while ($true) {
        $folderPath = $pwd.Path
        if (![string]::IsNullOrEmpty($folderPath) -and (Test-Path -Path $folderPath -PathType Container)) {
            Write-Log -message "Valid folder path entered: $folderPath"
            return $folderPath
        } else {
            Write-Host "Invalid directory. Please enter a valid directory." -ForegroundColor Red
            Write-Log -message "Invalid folder path entered: $folderPath" -isError $true
        }
    }
}

function Perform-RenamingTask {
    param (
        [bool]$removeUnderscores,
        [bool]$removeSpaces,
        [bool]$removeSpecialChars,
        [bool]$addPrefix,
        [bool]$removeFirstUnderscore,
        [string]$prefix,
        [string]$preserveChars,
        [string]$folderPath
    )

    $files = Get-ChildItem -Path $folderPath -File

    foreach ($file in $files) {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $extension = $file.Extension
        $newName = $baseName

        # Modify filename based on selected options
        if ($removeSpaces) {
            $newName = $newName -replace ' ', ''
        }
        if ($removeUnderscores) {
            $newName = Remove-ExtraUnderscores -filename $newName
        }
        if ($removeSpecialChars) {
            $newName = Remove-UnwantedCharacters -filename $newName -preserveChars $preserveChars
        }
        if ($removeFirstUnderscore) {
            $newName = $newName -replace '^_', ''
        }

        if ($addPrefix) {
            $newName = "$prefix`_$newName"
        }

        $newName = "$newName$extension"
        $newFilePath = Join-Path -Path $folderPath -ChildPath $newName

        if (Test-Path $newFilePath) {
            Write-Host "Can't Rename '$($file.Name)' to '$newName' Because A File With That Name Already Exists." -ForegroundColor Red
            Write-Log -message "Failed to rename '$($file.Name)' to '$newName': File already exists" -isError $true
            continue  # Skip to the next file without attempting to rename
        }

        try {
            Rename-Item -Path $file.FullName -NewName $newFilePath -ErrorAction Stop
            Write-Host "Renamed '$($file.Name)' to '$newName'" -ForegroundColor Green
            Write-Log -message "Renamed '$($file.Name)' to '$newName'"

            Update-UserActivity -username $env:UserName -activity "Renamed file '$($file.Name)'" -folder $folderPath
        } catch {
            Write-Host "Failed to rename '$($file.Name)': $_" -ForegroundColor Red
            Write-Log -message "Failed to rename '$($file.Name)': $_" -isError $true
        }
    }
}


function Replace-WordInFilenames {
    param (
        [string]$folderPath,
        [string]$oldWord,
        [string]$newWord
    )

    $files = Get-ChildItem -Path $folderPath -File

    foreach ($file in $files) {
        $newName = $file.Name -replace [Regex]::Escape($oldWord), $newWord
        if ($newName -ne $file.Name) {
            $newFilePath = Join-Path -Path $folderPath -ChildPath $newName
            Rename-Item -Path $file.FullName -NewName $newFilePath
            Write-Host "Renamed '$($file.Name)' to '$newName'" -ForegroundColor Green
            Write-Log -message "Renamed '$($file.Name)' to '$newName'"

            Update-UserActivity -username $env:UserName -activity "Replaced word '$oldWord' with '$newWord' in '$($file.Name)'" -folder $folderPath
        }
    }
}

do {
    Show-BannerAndMenu
    $folderPath = Get-ValidFolderPath

    $validOption = $false
    $attemptCount = 0  # Initialize attempt counter

    while (-not $validOption -and $attemptCount -lt 3) {
        $option = Read-Host "Enter your choice (1-7)"
        switch ($option) {
            1 {
                Perform-RenamingTask -removeUnderscores $true -removeSpaces $false -removeSpecialChars $false -addPrefix $false -removeFirstUnderscore $false -prefix $prefix -preserveChars $preserveChars -folderPath $folderPath
                $validOption = $true
            }
            2 {
                Perform-RenamingTask -removeUnderscores $false -removeSpaces $true -removeSpecialChars $false -addPrefix $false -removeFirstUnderscore $false -prefix $prefix -preserveChars $preserveChars -folderPath $folderPath
                $validOption = $true
            }
            3 {
                $preserveChars = "&"
                $userPreserveChars = Read-Host "Enter characters to preserve (besides _ and &):"
                $preserveChars += $userPreserveChars
                Perform-RenamingTask -removeUnderscores $false -removeSpaces $false -removeSpecialChars $true -addPrefix $false -removeFirstUnderscore $false -prefix $prefix -preserveChars $preserveChars -folderPath $folderPath
                $validOption = $true
            }
            4 {
                $prefix = Read-Host "Enter the prefix to add:"
                Perform-RenamingTask -removeUnderscores $false -removeSpaces $false -removeSpecialChars $false -addPrefix $true -removeFirstUnderscore $false -prefix $prefix -preserveChars $preserveChars -folderPath $folderPath
                $validOption = $true
            }
            5 {
                Perform-RenamingTask -removeUnderscores $false -removeSpaces $false -removeSpecialChars $false -addPrefix $false -removeFirstUnderscore $true -prefix $prefix -preserveChars $preserveChars -folderPath $folderPath
                $validOption = $true
            }
            6 {
                $oldWord = Read-Host "Enter the word to replace:"
                $newWord = Read-Host "Enter the new word:"
                Replace-WordInFilenames -folderPath $folderPath -oldWord $oldWord -newWord $newWord
                $validOption = $true
            }
            7 {
                Write-Host "Exiting..."
                Write-Log -message "User chose to exit the script"
                exit
            }
            default {
                Write-Host "Invalid option. Please try again."
                Write-Log -message "Invalid option entered: $option" -isError $true
                $attemptCount++  # Increment the attempt counter
                if ($attemptCount -lt 3) {
                    Write-Host "You have $($3 - $attemptCount) attempt(s) remaining." -ForegroundColor Yellow
                } else {
                    Write-Host "Too many invalid attempts. Exiting program..." -ForegroundColor Red
                    Write-Log -message "Too many invalid attempts. Exiting program..." -isError $true
                    exit  # Exit the script after 3 invalid attempts
                }
            }
        }
    }

    Write-Host "============================================================================"
    
    $continue = Read-Host "Do you want to perform another task? (yes/no)"
    while ($continue -ne "yes" -and $continue -ne "no") {
        Write-Host "Invalid input. Please enter 'yes' or 'no'." -ForegroundColor Yellow
        $continue = Read-Host "Do you want to perform another task? (yes/no)"
    }

} while ($continue -eq "yes")

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$msgBox = New-Object System.Windows.Forms.Form
$msgBox.StartPosition = "CenterScreen"
$msgBox.Width = 300
$msgBox.Height = 100

$msgLabel = New-Object System.Windows.Forms.Label
$msgLabel.Text = "Oopss!!! Something Went Wrong - Contact Dev....!!"
$msgLabel.AutoSize = $true
$msgLabel.TextAlign = "MiddleCenter"
$msgBox.Controls.Add($msgLabel)

[void]$msgBox.ShowDialog()
Write-Log -message "Script ended"
