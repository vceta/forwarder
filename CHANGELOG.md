# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.5.0] - 2026-01-21

### Added
- **PowerShell Script** (`forwarder.ps1`) - Native Windows PowerShell version (experimental)
  - Full feature parity with bash script
  - Parameter-based input with environment variable support
  - Auto port assignment using `Get-NetTCPConnection`
  - PowerShell comment-based help documentation
  - Proper error handling with `$ErrorActionPreference`
- **Comprehensive Installation Guide** (`INSTALLATION.md`)
  - System-wide installation instructions for Linux using `/usr/local/bin`
  - Detailed permission settings (755) and ownership configuration
  - macOS installation methods with Homebrew integration
  - Windows installation options: WSL, PowerShell, Git Bash, and wrappers
  - Troubleshooting section and verification steps
- **Bash Dependency** - Added Bash 4.0+ as explicit prerequisite in README.md
- **MIT License** - Added full MIT License text to README.md
- **Architecture Documentation** - Placeholder for architecture diagrams (architecture-diagram.md)

### Changed
- **Strict Mode** (`set -euo pipefail`) - Enhanced error handling in bash script
  - Exit immediately on non-zero status
  - Treat unset variables as errors
  - Pipeline returns status of last failed command
- **Documentation Structure** - Reorganized README.md
  - Clear distinction between bash and PowerShell scripts
  - Link to dedicated INSTALLATION.md guide
  - Updated version history section
- **Prerequisites** - Reordered and clarified dependencies
  - Bash listed as first dependency
  - Added version checking commands for all tools

### Improved
- Error handling and validation in bash script
- Documentation clarity and completeness
- User experience with better progress indicators

### Experimental
- PowerShell script (`forwarder.ps1`) is in experimental stage
- Recommended to use bash script via WSL or Git Bash on Windows for production

---

## [1.4.0] - 2026-01-14

### Added
- Strict mode execution (`set -euo pipefail`) for safer script execution
- Enhanced bastion host state checking
- Improved dependency validation (AWS CLI v2 and Session Manager Plugin)

### Changed
- Updated error handling throughout the script
- Improved documentation and help text
- Better signal handling for graceful shutdown

### Fixed
- Edge cases in auto-reconnect logic
- Session Manager Plugin path detection

---

## [1.3.0] - 2025-12-01

### Added
- **Auto-reconnect Feature** - Automatically reconnects when SSO session expires or connection is lost
- **Auto Port Assignment** - Finds and assigns free local port (49152-65535) with `-f` flag
- **Bastion State Checking** - Waits for bastion host to be in running state before connecting
- **Environment Variable Support** - Configure via environment variables or CLI options

### Features
- Remote port forwarding via AWS SSM Session Manager
- AWS SSO authentication with automatic token refresh
- Configurable parameters via command-line arguments:
  - `-h` Remote host DNS name
  - `-p` Remote port
  - `-l` Local port
  - `-a` AWS SSO profile
  - `-j` Bastion/Jump host instance ID
  - `-r` AWS region
  - `-f` Auto-assign free local port

### Technical Details
- Bash script with minimal dependencies
- Uses AWS CLI v2 and Session Manager Plugin
- Port forwarding via `AWS-StartPortForwardingSessionToRemoteHost` document

---

## [1.2.0] - 2025-11-15

### Added
- **Graceful Shutdown** - Handles `Ctrl+C` (SIGINT) and SIGTERM signals properly
  - Clean exit on interrupt signal
  - Proper cleanup of active sessions
  - User-friendly shutdown messages

### Changed
- Improved signal handling with trap commands
- Enhanced user feedback during shutdown

---

## [1.1.0] - 2025-11-01

### Added
- **Automatic Retry** - Connection automatically retries on failure
  - Retry loop with SSO re-authentication
  - Automatic session recovery
  - Continuous monitoring and reconnection

### Changed
- Enhanced connection stability
- Improved error messages for retry scenarios

---

## [1.0.0] - 2025-10-01

### Added
- **Initial Release** - Basic port forwarding functionality
  - Remote port forwarding via AWS SSM Session Manager
  - AWS SSO authentication
  - Command-line parameter support
  - **Dependency Checking** - Verifies AWS CLI v2 and Session Manager Plugin installation
  - Basic error handling

### Features
- Connect to remote resources through bastion host
- Configurable remote host, ports, AWS profile, and region
- Uses AWS Systems Manager Session Manager for secure connections
- Parameter-based configuration via command-line flags

### Technical Details
- Bash script implementation
- AWS CLI v2 integration
- Session Manager Plugin support
- Port forwarding document: `AWS-StartPortForwardingSessionToRemoteHost`

---

## [Unreleased]

### Planned
- Architecture diagram generation tools
- Additional Windows testing and improvements
- PowerShell script stability enhancements
- Automated testing framework
- Configuration file support (`.forwarderrc`)
- Multi-connection management
- Connection status monitoring dashboard

---

## Release Notes

### Version Numbering
- **Major version** (X.0.0): Breaking changes or major feature additions
- **Minor version** (0.X.0): New features, backwards compatible
- **Patch version** (0.0.X): Bug fixes and minor improvements

### Support
For issues, questions, or contributions, please refer to:
- [README.md](README.md) - Main documentation
- [INSTALLATION.md](INSTALLATION.md) - Installation instructions
- GitHub Issues - Bug reports and feature requests

---

## License

This project is licensed under the MIT License - see the LICENSE section in [README.md](README.md) for details.
