# 🗂️ File Renamer Script

## Overview

This PowerShell script is designed to help you efficiently rename files in a specified directory. It offers various functionalities, including removing extra underscores, unwanted special characters, spaces, and adding prefixes. It also supports word replacement within filenames. The script logs activities and errors, providing feedback on operations and user interactions.

## Features

- **Remove Extra Underscores**: Removes all but the first underscore from filenames. ✂️
- **Remove Spaces**: Eliminates spaces from filenames. 🚫
- **Remove Unwanted Characters**: Removes characters not specified by the user while preserving certain characters. 🧹
- **Add Prefix**: Adds a user-defined prefix to filenames. 🏷️
- **Remove First Underscore**: Removes the first underscore from filenames. 🆗
- **Replace Word in Filenames**: Replaces specified words in filenames with new ones. 🔄
- **Activity Logging**: Logs user activities and errors to a log file. 📜
- **User Interaction**: Prompts users for actions and preferences, with options for retrying or exiting. 💬

## Installation

1. **Clone or Download**: Obtain the script file from the repository or copy the code into a `.ps1` file. 📥

2. **Execution Policy**: Ensure that your PowerShell execution policy allows running scripts. You can set the policy with:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
   ```

3. **Run the Script**: Open PowerShell and navigate to the directory containing the script. Execute it with:
   ```powershell
   .\YourScriptName.ps1
   ```

## Usage

1. **Launch the Script**: Run the script from PowerShell. 🚀

2. **Select an Option**: Choose from the available options in the menu:
   - `1. Remove underscores (except the first one)` 🛠️
   - `2. Remove spaces` 🗑️
   - `3. Remove unwanted special characters` 🚫🔣
   - `4. Add prefix to filenames` 🏷️
   - `5. Remove the first underscore` 🆗
   - `6. Replace a word in filenames` 🔄
   - `7. Exit` ❌

3. **Follow Prompts**: Enter required details as prompted by the script (e.g., prefix, characters to preserve, words to replace). ✍️

4. **Review Logs**: Check the `file_renamer.log` in your user profile directory for detailed logs of the operations performed. 📜

5. **User Activity**: View or update the `last_user_activity.txt` file in your user profile directory to see the latest user activity. 👤

## Example

To remove extra underscores from filenames in a directory:

1. Choose option `1` from the menu. 🔧
2. The script will process files in the current directory, modifying filenames as specified. 🗂️

## Troubleshooting

- **Invalid Directory**: Ensure you enter a valid directory path. 🛣️
- **File Exists**: If a file with the new name already exists, the script will skip renaming and log the error. ⚠️

## License

This script is provided as-is. Use it at your own risk, and ensure you have backups of your files before running the script. 🛡️

## Contact

For issues or inquiries, please contact the developer or refer to the script's documentation. 📬

