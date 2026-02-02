 ![ Forwarder_logo](pics/forwarder.png) 
# AWS SSM Port Forwarding Script

This repository contains scripts for secure port forwarding to AWS resources through bastion hosts using AWS Systems Manager (SSM) Session Manager.

## Scripts

### `forwarder.sh` - Bash Script
A feature-rich bash script with auto-reconnect, SSO authentication, and automatic port assignment.

### `forwarder.ps1` - PowerShell Script (⚠️ Experimental)
PowerShell version with the same features, native to Windows environments. **Note:** This script is currently in experimental stage. For production use, we recommend using the bash script via WSL or Git Bash on Windows.

---

## Prerequisites

Before using these scripts, ensure you have:

1. **Bash 4.0 or higher** installed
   - Most Linux distributions and macOS come with Bash pre-installed
   - For Windows, use WSL, Git Bash, or Cygwin
   ```bash
   # Check Bash version
   bash --version
   ```

2. **AWS CLI v2** installed
   - [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
   ```bash
   # Check installation
   aws --version
   ```

3. **AWS Session Manager Plugin** installed
   - [Installation Guide](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)
   ```bash
   # Check installation
   session-manager-plugin --version
   ```

4. **AWS SSO configured** with appropriate profile
   - [SSO Configuration Guide](https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html)
   - [SSO Setup Tutorial](https://docs.aws.amazon.com/singlesignon/latest/userguide/getting-started.html)
   ```bash
   # Configure SSO
   aws configure sso
   aws login --profile your_profile_name
   export AWS_PROFILE=your_profile_name
   ```

5. **Required IAM permissions**
   
   Your IAM user or role must have the following permissions:

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "SSMSessionManager",
         "Effect": "Allow",
         "Action": [
           "ssm:StartSession"
         ],
         "Resource": [
           "arn:aws:ec2:*:*:instance/your_bastion_id",
           "arn:aws:ssm:*:*:document/AWS-StartPortForwardingSessionToRemoteHost"
         ],
         "Condition": {
           "BoolIfExists": {
             "ssm:SessionDocumentAccessCheck": "true"
           }
         }
       },
       {
         "Sid": "EC2Describe",
         "Effect": "Allow",
         "Action": [
           "ec2:DescribeInstances",
           "ec2:DescribeInstanceStatus"
         ],
         "Resource": "arn:aws:ec2:*:*:instance/your_bastion_id",
       },
       {
         "Sid": "SSMTerminateSession",
         "Effect": "Allow",
         "Action": [
           "ssm:TerminateSession",
           "ssm:ResumeSession"
         ],
         "Resource": "arn:aws:ssm:*:*:session/${aws:username}-*"
       }
     ]
   }
   ```

---

## Installation & Setup

📖 **For detailed installation instructions for Linux, macOS, and Windows, see [INSTALLATION.md](INSTALLATION.md)**

### 1. Set Execute Permissions (Bash Script)

After cloning or downloading the script, make it executable:

```bash
# Set execute permission for forwarder.sh
chmod +x forwarder.sh

# Verify permissions
ls -la forwarder.sh
```

**Expected output:**
```
-rwxr-xr-x 1 user group 5432 Jan 14 12:00 forwarder.sh
```

### 2. Verify Script Syntax (Optional)

```bash
# Install shellcheck (if not already installed)
sudo apt install shellcheck

# Check script for issues
shellcheck forwarder.sh
```

---

## CloudWatch SSM logging

**For detailed SSM log install CloudWatch agent and push logs into CloudWatch, instruction see [CLOUDWATCH-MONITORING.md](CLOUDWATCH-MONITORING.md)**


## Usage

### ⚠️ Important Before Running

1. **Export AWS_PROFILE** environment variable:
   ```bash
   export AWS_PROFILE="your-aws-profile-name"
   ```

2. **Keep the terminal window open** while the forwarder is running. Closing the terminal will terminate the port forwarding session.

3. **To stop the forwarder**, press `Ctrl+C` in the terminal where it's running.

---

### forwarder.sh - Advanced Usage

#### Quick Start (Using Defaults)

```bash
# Export your AWS profile first
export AWS_PROFILE="my-aws-profile"

# Run the forwarder
./forwarder.sh
```

#### With Environment Variables

```bash
export REMOTE_HOST="my-database.rds.amazonaws.com"
export AWS_PROFILE="my-aws-profile"
export JUMP_HOST="i-1234567890abcdef"
export REMOTE_PORT="5432"
export LOCAL_PORT="15432"
export REGION="us-east-1"

./forwarder.sh
```

#### With Command Line Options

```bash
# Export your AWS profile first
export AWS_PROFILE="my-aws-profile"

# Run with command line options
./forwarder.sh -h my-database.rds.amazonaws.com \
               -a my-aws-profile \
               -j i-1234567890abcdef \
               -p 5432 \
               -l 15432 \
               -r us-east-1
```

#### Auto-assign Free Local Port

```bash
./forwarder.sh -f -h my-database.rds.amazonaws.com -a my-profile
```

#### Available Options

| Option | Description | Environment Variable | Default |
|--------|-------------|---------------------|---------|
| `-h`   | Remote host DNS name | `REMOTE_HOST` | `dev-webapp-nhs-db.ckn9btrppujn.eu-west-2.rds.amazonaws.com` |
| `-p`   | Remote port | `REMOTE_PORT` | `5432` |
| `-l`   | Local port | `LOCAL_PORT` | `15432` |
| `-a`   | AWS SSO profile | `AWS_PROFILE` | `akrivia-development` |
| `-j`   | Bastion/Jump host instance ID | `JUMP_HOST` | `i-0a9ce8d5281f39d6b` |
| `-r`   | AWS region | `REGION` | `eu-west-2` |
| `-f`   | Auto-assign free local port | N/A | N/A |

---

## Features

- ✅ **Auto-reconnect** - Automatically reconnects when SSO session expires or connection is lost
- ✅ **Auto port assignment** - Finds and assigns a free local port (49152-65535)
- ✅ **Bastion state checking** - Waits for bastion host to be in running state
- ✅ **Environment variable support** - Configure via env vars or CLI options
- ✅ **Graceful shutdown** - Handles Ctrl+C (SIGINT) and SIGTERM signals
- ✅ **Strict mode** - Uses `set -euo pipefail` for safer execution
- ✅ **Dependency checking** - Verifies AWS CLI v2 and Session Manager Plugin

---

## Troubleshooting

### Permission Denied Error

```bash
# Error: Permission denied
bash: ./forwarder.sh: Permission denied

# Solution: Set execute permission
chmod +x forwarder.sh
```

### AWS CLI Not Found

```bash
# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Session Manager Plugin Not Found

```bash
# Install Session Manager Plugin (Ubuntu/Debian)
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb
```

### SSO Login Issues

```bash
# Reconfigure SSO
aws sso login --profile your-profile-name

# Or reconfigure from scratch
aws configure sso
```

### Port Already in Use

```bash
# Use auto port assignment with forwarder.sh
./forwarder.sh -f

# Or specify a different local port
./forwarder.sh -l 15433
```

---

## Examples

### Example 1: Connect to RDS Postgress Database

```bash
# Start port forwarding
./forwarder.sh -h my-db.rds.amazonaws.com -p 5432 -l 5432

# In any other terminal, connect using psql
psql -h localhost -p 5432 -U myuser -d mydatabase
```

### Example 2: MySQL Connection

```bash
# Start port forwarding
./forwarder.sh -h my-db.rds.amazonaws.com -p 3306 -l 3306

# In another terminal, connect using mysql client
mysql -h localhost -P 3306 -u myuser -p mydatabase
```

### Example 3: Auto Port with Connection String

```bash
# Start with auto port
./forwarder.sh -f -h my-db.rds.amazonaws.com
# Output: [Info] Auto assign local exposed port to '54321'

# Use the assigned port
psql postgresql://user:pass@localhost:54321/mydb
```

---

## Stopping the Scripts

Press `Ctrl+C` to gracefully stop the port forwarding session.

The script will:
1. Catch the SIGINT signal
2. Display a shutdown message
3. Clean up and exit

---

## Support

For issues or questions, please contact the Akrivia Health Infrastructure Team.

---

## Version History

** [CHNAGELOG.md](CHANGELOG.md)**

## License

MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Contributing

Contributions are welcome! Please follow the Community Contribution Rules.
