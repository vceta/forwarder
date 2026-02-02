# Installation Guide - Making forwarder.sh Executable from Command Line

This guide explains how to make the `forwarder.sh` script executable from anywhere in your terminal on Linux, Windows, and macOS.

---

## 📋 Table of Contents

- [Linux](#-linux)
- [macOS](#-macos)
- [Windows](#-windows)
  - [Option 1: WSL (Recommended)](#option-1-wsl-windows-subsystem-for-linux-recommended)
  - [Option 2: Git Bash](#option-2-git-bash)
  - [Option 3: PowerShell Wrapper](#option-3-powershell-wrapper)

---

## 🐧 Linux

### System-Wide Installation to /usr/local/bin (Recommended)

This method installs the script system-wide in `/usr/local/bin`, which is already in the system PATH and accessible to all users. This is the standard location for user-installed executables.

1. **Copy the script to /usr/local/bin:**
   ```bash
   sudo cp /path/your_download_location/forwarder.sh /usr/local/bin/forwarder
   ```

2. **Set ownership to root (security best practice):**
   ```bash
   sudo chown root:root /usr/local/bin/forwarder
   ```

3. **Set proper permissions (readable and executable by all, writable only by root):**
   ```bash
   sudo chmod 755 /usr/local/bin/forwarder
   ```
   
   **Permission breakdown (755):**
   - `7` (owner/root): read + write + execute
   - `5` (group): read + execute
   - `5` (others): read + execute

4. **Verify permissions:**
   ```bash
   ls -l /usr/local/bin/forwarder
   ```
   
   **Expected output:**
   ```
   -rwxr-xr-x 1 root root 12345 Jan 21 10:30 /usr/local/bin/forwarder
   ```

5. **Test the installation:**
   ```bash
   which forwarder
   forwarder --help
   ```

### Alternative: Using Symlink to /usr/local/bin

This method creates a symbolic link instead of copying, useful for development as changes to the original script are reflected immediately.

1. **Make the original script executable:**
   ```bash
   chmod +x /path/your_download_location/forwarder.sh
   ```

2. **Create a symbolic link in /usr/local/bin:**
   ```bash
   sudo ln -s /path/your_download_location/forwarder.sh /usr/local/bin/forwarder
   ```

3. **Verify the symlink:**
   ```bash
   ls -l /usr/local/bin/forwarder
   ```
   
   **Expected output:**
   ```
   lrwxrwxrwx 1 root root 52 Jan 21 10:30 /usr/local/bin/forwarder -> /path/to/your_download_location/forwarder.sh
   ```

4. **Test the installation:**
   ```bash
   which forwarder
   forwarder --help
   ```

### User-Level Installation (Optional)

If you don't have sudo access or prefer a user-level installation:

1. **Create a bin directory in your home folder:**
   ```bash
   mkdir -p ~/.local/bin
   ```

2. **Copy the script:**
   ```bash
   cp /path/your_download_location/forwarder.sh ~/.local/bin/forwarder
   ```

3. **Make it executable:**
   ```bash
   chmod 755 ~/.local/bin/forwarder
   ```

4. **Add to PATH (if not already):**
   
   For **Bash** (add to `~/.bashrc`):
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```
   
   For **Zsh** (add to `~/.zshrc`):
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

5. **Verify installation:**
   ```bash
   which forwarder
   forwarder --help
   ```

---

## 🍎 macOS

### Method 1: Add Script to PATH (Recommended)

1. **Create a bin directory in your home folder:**
   ```bash
   mkdir -p ~/bin
   ```

2. **Copy the script to the bin directory:**
   ```bash
   cp /path/to/forwarder/forwarder.sh ~/bin/forwarder
   ```

3. **Make the script executable:**
   ```bash
   chmod +x ~/bin/forwarder
   ```

4. **Add ~/bin to your PATH:**
   
   For **Zsh** (default on macOS Catalina and later, add to `~/.zshrc`):
   ```bash
   echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```
   
   For **Bash** (older macOS versions, add to `~/.bash_profile`):
   ```bash
   echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bash_profile
   source ~/.bash_profile
   ```

5. **Verify installation:**
   ```bash
   which forwarder
   forwarder --help
   ```

### Method 2: Create Symlink to /usr/local/bin

1. **Make the script executable:**
   ```bash
   chmod +x /path/to/forwarder/forwarder.sh
   ```

2. **Create a symlink:**
   ```bash
   sudo ln -s /path/to/forwarder/forwarder.sh /usr/local/bin/forwarder
   ```

3. **Verify installation:**
   ```bash
   which forwarder
   forwarder --help
   ```

### Method 3: Using Homebrew (Advanced)

1. **Create a formula directory:**
   ```bash
   mkdir -p $(brew --prefix)/Homebrew/Library/Taps/homebrew/homebrew-core/Formula
   ```

2. **Create a simple script wrapper and install manually to brew bin:**
   ```bash
   cp /path/to/forwarder/forwarder.sh $(brew --prefix)/bin/forwarder
   chmod +x $(brew --prefix)/bin/forwarder
   ```

3. **Verify installation:**
   ```bash
   which forwarder
   forwarder --help
   ```

---

## 🪟 Windows

### Option 1: WSL (Windows Subsystem for Linux) - Recommended for Bash Script

WSL provides the best compatibility for bash scripts on Windows.

1. **Install WSL (if not already installed):**
   ```powershell
   wsl --install
   ```

2. **Open WSL terminal and follow the Linux bash script instructions above** to install `forwarder.sh`

3. **Verify installation:**
   ```bash
   which forwarder
   forwarder --help
   ```

### Option 2: Native PowerShell Script (⚠️ Experimental)

> **⚠️ Note:** The PowerShell script `forwarder.ps1` is currently in **experimental stage**. For production use, we recommend using the bash script via WSL (Option 1) or Git Bash (Option 3).

Use the native PowerShell script `forwarder.ps1` if you prefer a Windows-native solution.

1. **Copy the script to a directory in your PATH:**
   ```powershell
   # Create Scripts directory if it doesn't exist
   New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\Scripts"
   
   # Copy the PowerShell script
   Copy-Item "C:\path\to\your_download_location\forwarder.ps1" "$env:USERPROFILE\Scripts\forwarder.ps1"
   ```

2. **Add Scripts directory to PATH (if not already):**
   ```powershell
   # Add to user PATH
   $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
   $scriptsPath = "$env:USERPROFILE\Scripts"
   
   if ($userPath -notlike "*$scriptsPath*") {
       [Environment]::SetEnvironmentVariable(
           "Path",
           "$userPath;$scriptsPath",
           "User"
       )
   }
   
   # Reload PATH in current session
   $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
   ```

3. **Enable script execution (if needed):**
   ```powershell
   # Allow running scripts from the current user
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

4. **Verify installation:**
   ```powershell
   Get-Command forwarder.ps1
   
   # Test the script
   forwarder.ps1 -?
   ```

5. **Usage:**
   ```powershell
   # Set AWS profile
   $env:AWS_PROFILE = "your-profile-name"
   
   # Run the script
   forwarder.ps1
   
   # Or with parameters
   forwarder.ps1 -RemoteHost "my-db.rds.amazonaws.com" -AwsProfile "my-profile" -AutoPort
   ```

### Option 3: Git Bash

Git Bash provides a bash-like environment on Windows for running the bash script.

1. **Install Git for Windows** (includes Git Bash):
   - Download from: https://git-scm.com/download/win
   - Install with default options

2. **Open Git Bash and create bin directory:**
   ```bash
   mkdir -p ~/bin
   ```

3. **Copy the script:**
   ```bash
   cp /c/path/to/forwarder/forwarder.sh ~/bin/forwarder
   ```

4. **Make executable:**
   ```bash
   chmod +x ~/bin/forwarder
   ```

5. **Add to PATH (add to `~/.bashrc`):**
   ```bash
   echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

6. **Verify installation:**
   ```bash
   which forwarder
   forwarder --help
   ```

### Option 4: Bash Script Wrapper (Advanced)

Create a wrapper to call the bash script from PowerShell or CMD.

1. **Create a PowerShell script** `forwarder.ps1` in your user scripts directory:
   
   ```powershell
   # Create scripts directory
   New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\Scripts"
   ```

2. **Create the wrapper script:**
   ```powershell
   @'
   #!/usr/bin/env pwsh
   # PowerShell wrapper for forwarder.sh
   
   $scriptPath = "C:\path\to\forwarder\forwarder.sh"
   
   # Run with Git Bash
   & "C:\Program Files\Git\bin\bash.exe" $scriptPath $args
   
   # Or run with WSL
   # wsl bash $scriptPath $args
   '@ | Out-File -FilePath "$env:USERPROFILE\Scripts\forwarder.ps1" -Encoding UTF8
   ```

3. **Add Scripts directory to PATH:**
   ```powershell
   # Add to user PATH
   $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
   $scriptsPath = "$env:USERPROFILE\Scripts"
   
   if ($userPath -notlike "*$scriptsPath*") {
       [Environment]::SetEnvironmentVariable(
           "Path",
           "$userPath;$scriptsPath",
           "User"
       )
   }
   
   # Reload PATH in current session
   $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
   ```

4. **Enable script execution (if needed):**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

5. **Create a batch file wrapper** (Alternative - simpler):
   
   Create `forwarder.bat` in `C:\Windows\System32` or any directory in PATH:
   ```batch
   @echo off
   "C:\Program Files\Git\bin\bash.exe" "C:\path\to\forwarder\forwarder.sh" %*
   ```

6. **Verify installation:**
   ```powershell
   Get-Command forwarder
   forwarder --help
   ```

---

## ✅ Verification

After installation on any platform, verify that the script is accessible:

```bash
# Check if command is found
which forwarder
# or on Windows PowerShell:
# Get-Command forwarder

# Test the script
forwarder --help

# Check version (if implemented)
forwarder --version

# Try running with default settings
export AWS_PROFILE="your-profile"
forwarder
```

---

## 🔧 Troubleshooting

### Command Not Found

**Linux/macOS:**
```bash
# Verify PATH includes the directory
echo $PATH

# Reload shell configuration
source ~/.bashrc  # or ~/.zshrc or ~/.bash_profile

# Check if script has execute permission
ls -la ~/bin/forwarder
```

**Windows:**
```powershell
# Verify PATH
$env:Path

# Restart terminal or reload PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

### Permission Denied

**Linux/macOS:**
```bash
# Add execute permission
chmod +x ~/bin/forwarder
```

**Windows (Git Bash/WSL):**
```bash
# Add execute permission
chmod +x ~/bin/forwarder

# On Windows, you may also need to check file system permissions
```

### Script Runs but Can't Find Dependencies

Make sure AWS CLI and Session Manager Plugin are installed:

```bash
# Check AWS CLI
aws --version

# Check Session Manager Plugin
session-manager-plugin --version
```

If missing, refer to the [Prerequisites section in README.md](README.md#prerequisites).

---

## 🔄 Updating the Script

When you update the script, follow these steps:

**If using symlink:**
```bash
# The symlink will automatically use the updated script
# Just update the original file
```

**If using copy to ~/bin:**
```bash
# Re-copy the updated script
cp /path/to/forwarder/forwarder.sh ~/bin/forwarder
chmod +x ~/bin/forwarder
```

**Verify the update:**
```bash
forwarder --version  # if version is implemented
# or check the file date
ls -la ~/bin/forwarder
```

---

## 🎯 Best Practices

1. **Use symlinks** instead of copies when possible - this ensures you're always using the latest version
2. **Keep scripts in version control** - don't modify the installed copy directly
3. **Use meaningful names** - `forwarder` is clearer than `forwarder.sh` for a command
4. **Document dependencies** - note which tools are required (AWS CLI, SSM Plugin)
5. **Test after installation** - always verify the script works after setup

---

## 📚 Additional Resources

- [Linux Filesystem Hierarchy Standard](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html)
- [macOS Command Line Primer](https://developer.apple.com/library/archive/documentation/OpenSource/Conceptual/ShellScripting/CommandLInePrimer/CommandLine.html)
- [Windows Subsystem for Linux Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [Git for Windows](https://git-scm.com/download/win)
- [PowerShell Execution Policies](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies)

---

## 💡 Quick Reference

| Platform | Recommended Method | Script | Command to Run |
|----------|-------------------|--------|----------------|
| **Linux** | Copy to /usr/local/bin | forwarder.sh | `forwarder` |
| **macOS** | Copy to /usr/local/bin | forwarder.sh | `forwarder` |
| **Windows** | WSL (recommended) | forwarder.sh | `forwarder` (in WSL) |
| **Windows** | PowerShell (⚠️ experimental) | forwarder.ps1 | `forwarder.ps1` |
| **Windows** | Git Bash | forwarder.sh | `forwarder` (in Git Bash) |
