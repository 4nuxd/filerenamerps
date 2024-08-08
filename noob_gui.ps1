Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define the banner text
$banner = @"
============================================================================
||         __________     ____                                            ||
||        / ___/ ___/    / __ \___  ____  ____ _____ ___  ___  _____      ||
||        \__ \\__ \    / /_/ / _ \/ __ \/ __ \/ __ \__ \/ _ \/ ___/      ||
||       ___/ /__/ /   / _, _/  __/ / / / /_/ / / / / / /  __/ /          ||
||      /____/____/   /_/ |_|\___/_/ /_/\__,_/_/ /_/ /_/\___/_/           ||
||                                                                        ||
============================================================================
||      Description : A Simple File Renamer                               ||     
||      Current Version : v0.0.1 [ Stable ]                               ||    
||      Author : Who knows where curiosity leads Us                       ||     
============================================================================
============================================================================
"@

# Function Definitions
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

function Perform-RenamingTask {
    param (
        [bool]$removeUnderscores,
        [bool]$removeSpaces,
        [bool]$removeSpecialChars,
        [bool]$addPrefix,
        [bool]$removeFirstUnderscore,
        [string]$prefix,
        [string]$preserveChars,
        [string]$folderPath,
        [string]$oldWord = "",
        [string]$newWord = ""
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

        if ($oldWord -and $newWord) {
            $newName = $newName -replace [Regex]::Escape($oldWord), $newWord
        }

        $newName = "$newName$extension"
        $newFilePath = Join-Path -Path $folderPath -ChildPath $newName

        if (Test-Path $newFilePath) {
            Write-Host "Cannot rename '$($file.Name)' to '$newName' because a file with that name already exists." -ForegroundColor Red
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

# Define the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Noob Renamer GUI"
$form.Width = 800
$form.Height = 700
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# Add banner to the form
$bannerLabel = New-Object System.Windows.Forms.Label
$bannerLabel.Text = $banner
$bannerLabel.AutoSize = $true
$bannerLabel.Font = New-Object System.Drawing.Font("Courier New", 10, [System.Drawing.FontStyle]::Regular)
$bannerLabel.Location = New-Object System.Drawing.Point(70, 10)
$bannerLabel.Size = New-Object System.Drawing.Size(760, 130)
$form.Controls.Add($bannerLabel)

# Folder Path
$lblFolderPath = New-Object System.Windows.Forms.Label
$lblFolderPath.Text = "Current Directory:"
$lblFolderPath.Location = New-Object System.Drawing.Point(20, 212)
$form.Controls.Add($lblFolderPath)

$txtFolderPath = New-Object System.Windows.Forms.TextBox
$txtFolderPath.Location = New-Object System.Drawing.Point(120, 210)
$txtFolderPath.Width = 450
$txtFolderPath.Text = (Get-Location).Path
$txtFolderPath.ReadOnly = $true
$form.Controls.Add($txtFolderPath)

$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Text = "Browse"
$btnBrowse.Location = New-Object System.Drawing.Point(570, 208)
$btnBrowse.Width = 80
$form.Controls.Add($btnBrowse)

# Event handler for Browse button
$btnBrowse.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtFolderPath.Text = $folderBrowser.SelectedPath
    }
})

# Prefix
$lblPrefix = New-Object System.Windows.Forms.Label
$lblPrefix.Text = "Prefix:"
$lblPrefix.Location = New-Object System.Drawing.Point(20, 510)
$form.Controls.Add($lblPrefix)

$txtPrefix = New-Object System.Windows.Forms.TextBox
$txtPrefix.Location = New-Object System.Drawing.Point(170, 510)
$txtPrefix.Width = 200
$form.Controls.Add($txtPrefix)

# Options
$chkRemoveSpaces = New-Object System.Windows.Forms.CheckBox
$chkRemoveSpaces.Text = "Remove Spaces"
$chkRemoveSpaces.Location = New-Object System.Drawing.Point(20, 270)
$chkRemoveSpaces.Size = New-Object System.Drawing.Size(150, 20)
$form.Controls.Add($chkRemoveSpaces)

$chkRemoveUnderscores = New-Object System.Windows.Forms.CheckBox
$chkRemoveUnderscores.Text = "Remove Extra Underscores"
$chkRemoveUnderscores.Location = New-Object System.Drawing.Point(20,300)
$chkRemoveUnderscores.Size = New-Object System.Drawing.Size(250, 20)
$form.Controls.Add($chkRemoveUnderscores)

$chkRemoveSpecialChars = New-Object System.Windows.Forms.CheckBox
$chkRemoveSpecialChars.Text = "Remove Special Characters"
$chkRemoveSpecialChars.Location = New-Object System.Drawing.Point(20,330)
$chkRemoveSpecialChars.Size = New-Object System.Drawing.Size(250, 20)
$form.Controls.Add($chkRemoveSpecialChars)

$chkAddPrefix = New-Object System.Windows.Forms.CheckBox
$chkAddPrefix.Text = "Add Prefix"
$chkAddPrefix.Location = New-Object System.Drawing.Point(20,360)
$chkAddPrefix.Size = New-Object System.Drawing.Size(250, 20)
$form.Controls.Add($chkAddPrefix)

$chkRemoveFirstUnderscore = New-Object System.Windows.Forms.CheckBox
$chkRemoveFirstUnderscore.Text = "Remove First Underscore"
$chkRemoveFirstUnderscore.Location = New-Object System.Drawing.Point(20,390)
$chkRemoveFirstUnderscore.Size = New-Object System.Drawing.Size(250, 20)
$form.Controls.Add($chkRemoveFirstUnderscore)

$lblOldWord = New-Object System.Windows.Forms.Label
$lblOldWord.Text = "Old Word (to replace):"
$lblOldWord.Location = New-Object System.Drawing.Point(20, 420)
$lblOldWord.Size = New-Object System.Drawing.Size(150, 20)
$form.Controls.Add($lblOldWord)

$txtOldWord = New-Object System.Windows.Forms.TextBox
$txtOldWord.Location = New-Object System.Drawing.Point(170, 415)
$txtOldWord.Width = 200
$form.Controls.Add($txtOldWord)

$lblNewWord = New-Object System.Windows.Forms.Label
$lblNewWord.Text = "New Word (replacement):"
$lblNewWord.Location = New-Object System.Drawing.Point(20, 450)
$lblNewWord.Size = New-Object System.Drawing.Size(150, 20)
$form.Controls.Add($lblNewWord)

$txtNewWord = New-Object System.Windows.Forms.TextBox
$txtNewWord.Location = New-Object System.Drawing.Point(170, 445)
$txtNewWord.Width = 200
$form.Controls.Add($txtNewWord)

# Preserve Characters
$lblPreserveChars = New-Object System.Windows.Forms.Label
$lblPreserveChars.Text = "Characters to Preserve:"
$lblPreserveChars.Location = New-Object System.Drawing.Point(20, 480)
$lblPreserveChars.Size = New-Object System.Drawing.Size(150, 20)
$form.Controls.Add($lblPreserveChars)

$txtPreserveChars = New-Object System.Windows.Forms.TextBox
$txtPreserveChars.Location = New-Object System.Drawing.Point(170, 480)
$txtPreserveChars.Width = 200
$form.Controls.Add($txtPreserveChars)

# Rename Button
$btnRename = New-Object System.Windows.Forms.Button
$btnRename.Text = "Rename"
$btnRename.Location = New-Object System.Drawing.Point(680, 510)
$form.Controls.Add($btnRename)

# Output
$txtOutput = New-Object System.Windows.Forms.TextBox
$txtOutput.Location = New-Object System.Drawing.Point(20, 550)
$txtOutput.Width = 760
$txtOutput.Height = 50
$txtOutput.Multiline = $true
$txtOutput.ScrollBars = "Vertical"
$txtOutput.ReadOnly = $true
$form.Controls.Add($txtOutput)

# Create a feedback label
$lblPasswordFeedback = New-Object System.Windows.Forms.Label
$lblPasswordFeedback.Text = "Crafted By Noob...!!!"
$lblPasswordFeedback.ForeColor = [System.Drawing.Color]::DarkGreen
$lblPasswordFeedback.Location = New-Object System.Drawing.Point(325, 630)  # Adjust location as needed
$lblPasswordFeedback.Width = 300
$form.Controls.Add($lblPasswordFeedback)

# Add Progress Bar Control
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(555, 450)
$progressBar.Width = 200
$form.Controls.Add($progressBar)

# Event handler for Rename button
$btnRename.Add_Click({
    $folderPath = $txtFolderPath.Text
    $prefix = $txtPrefix.Text
    $preserveChars = $txtPreserveChars.Text
    $oldWord = $txtOldWord.Text
    $newWord = $txtNewWord.Text
    $removeUnderscores = $chkRemoveUnderscores.Checked
    $removeSpaces = $chkRemoveSpaces.Checked
    $removeSpecialChars = $chkRemoveSpecialChars.Checked
    $addPrefix = $chkAddPrefix.Checked
    $removeFirstUnderscore = $chkRemoveFirstUnderscore.Checked
 
Perform-RenamingTask -removeUnderscores $removeUnderscores -removeSpaces $removeSpaces -removeSpecialChars $removeSpecialChars -addPrefix $addPrefix -prefix $prefix -preserveChars $preserveChars -folderPath $folderPath -oldWord $oldWord -newWord $newWord
	
	$files = Get-ChildItem -Path $folderPath -File
    $totalFiles = $files.Count
    $progressBar.Maximum = $totalFiles
    $progressBar.Value = 0
	foreach ($file in $files) {
        $progressBar.Value++
    }

    $txtOutput.Text = "Renaming completed. Thanks Noob Later"
})


# Add Tooltips
$tooltip = New-Object System.Windows.Forms.ToolTip
$tooltip.SetToolTip($txtPrefix, "Specify a prefix to add to the beginning of each filename.")
$tooltip.SetToolTip($chkRemoveSpaces, "Remove all spaces from the filenames.")
$tooltip.SetToolTip($chkRemoveUnderscores, "Remove extra underscores from the filenames.")
$tooltip.SetToolTip($chkRemoveSpecialChars, "Remove special characters from the filenames.")
$tooltip.SetToolTip($chkAddPrefix, "Add a specified prefix to the filenames.")
$tooltip.SetToolTip($chkRemoveFirstUnderscore, "Remove the first underscore from the filenames.")
$tooltip.SetToolTip($txtOldWord, "Specify a word to replace in the filenames.")
$tooltip.SetToolTip($txtNewWord, "Specify the new word to replace the old word in the filenames.")
$tooltip.SetToolTip($txtPreserveChars, "Specify characters to preserve when removing special characters.")

# Display User Activity
$lblUserActivity = New-Object System.Windows.Forms.Label
$lblUserActivity.Text = "Last User Activity:"
$lblUserActivity.Location = New-Object System.Drawing.Point(350, 270)
$form.Controls.Add($lblUserActivity)

$txtUserActivity = New-Object System.Windows.Forms.TextBox
$txtUserActivity.Location = New-Object System.Drawing.Point(455, 265)
$txtUserActivity.Width = 300
$txtUserActivity.Height = 100
$txtUserActivity.Multiline = $true
$txtUserActivity.ReadOnly = $true
$txtUserActivity.ScrollBars = "Vertical"
$txtUserActivity.Text = Display-UserActivity
$form.Controls.Add($txtUserActivity)

# Show the form
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
