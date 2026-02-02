#!/bin/bash
# ==============================================================================
# DESCRIPTION:  Remote port forwarding script via AWS SSM Session Manager
#               Advanced version with auto-reconnect, SSO authentication,
#               auto port assignment, and bastion host state checking for connection
# AUTHOR:       Petro Sydor 
# VERSION:      1.5.0 (2026-01-14)
# RULES/LICENSE: MIT License / Community Contribution Rules
# ==============================================================================
# SETTINGS (Strict Mode)
set -euo pipefail
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error.
# -o pipefail: The return value of a pipeline is the status of the last command 
#              to exit with a non-zero status.
# ==============================================================================

# Remote port forwarding script via AWS SSM Session Manager script v1.5
# You can redefine the following variables via command line arguments or use the default values set below

RDS=${REMOTE_HOST:-'cluoud-db.abcdefght1.eu-west-1.rds.amazonaws.com'} # Redefine remote host/database AWS DNS name
AWS_PROFILE=${AWS_PROFILE:-'your-profile'} # Redefine default AWS SSO profile here
BASTION_HOST=${JUMP_HOST:-'i-1234567890'} # Redefine default bastion host instance id
REMOTE_PORT=${REMOTE_PORT:-'5432'} # Redefine remote port here
LOCAL_PORT=${LOCAL_PORT:-'15432'} # Redifine defualt local port here
REGION=${REGION:-'eu-west-1'} # Redefine default region here


# Do not change anything below this line
VERSION='1.5'
BASTION_CHECK_SLEEP_INTERVAL=15 # Bastion host check sleep interval in seconds

echo "Remote port forwarding script v.${VERSION} via AWS SSM Session Manager

 - allow to reconfigure parameters via args. You could use with other wrappers or command line execution
 - check of the jump/bastion host is in the running state
 - auto reconnect when SSO seesion will be expired or connection lost
 - auto port assignment for local exposed port

OPTIONS:

    -h    Redefine remote host for connection (environment variable REMOTE_HOST, default: '${RDS}')
    -p    Redefine remote port for connection (environment variable REMOTE_PORT, default: '${REMOTE_PORT}')
    -l    Redefine local port for exposing (environment variable LOCAL_PORT, default: '${LOCAL_PORT}')
    -a    Redefine AWS SSO profile (environment variable AWS_PROFILE, default: '${AWS_PROFILE}')
    -j    Redefine jump/bastion host instance id (environment variable JUMP_HOST, default: '${BASTION_HOST}')
    -r    Redefine AWS region (environment variable REGION, default: '${REGION}')
    -f    Auto assign free local port for exposing. Will override LOCAL PORT (No value required)


USAGE:
  
    # ${0} -h REMOTE-HOST-DNS-NAME -a SSM-PROFILE -p REMOTE-PORT -l LOCAL-PORT -j BASTION-INSTANCE-ID -r REGION -f
    or
    # ${0} -h dev.rds.amazon.com -a my-profile -j i-123 -l 5432 -p 5432 -r eu-west-2

INFO: 
    Ctrl+C (SIGINT) to stop auto recconect
" 

# This bit will find a free local port (between 49152–65535)
find_free_port() {
  while true; do
    PORT=$(shuf -i 49152-65535 -n 1)
    if ! lsof -i TCP:$PORT >/dev/null 2>&1; then
      echo $PORT
      return
    fi
  done
}

while getopts "h:p:l:a:j:r:f" opt; do
  case $opt in
	h)
  	RDS="$OPTARG"
  	echo "[Info] Redefined remote host for connection to: '${RDS}'"
  	;;
	p)
    REMOTE_PORT="$OPTARG"
  	echo "[Info] Redefined remote port for connection to: '${REMOTE_PORT}'"
  	;;
  l)
    LOCAL_PORT="$OPTARG"
  	echo "[Info] Redefined local port for exposing to: '${LOCAL_PORT}'"
  	;;
  a)
    AWS_PROFILE="$OPTARG"
  	echo "[Info] Redefined AWS SSO profile to: '${AWS_PROFILE}'"
  	;;
   j)
    BASTION_HOST="$OPTARG"
  	echo "[Info] Redefined jump/bastion host to: '${BASTION_HOST}'"
  	;;
   r)
    REGION="$OPTARG"
  	echo "[Info] Redefined AWS region to: '${REGION}'"
  	;;
   f)
    LOCAL_PORT=$(find_free_port)
  	echo "[Info] Auto assign local exposed port to '${LOCAL_PORT}'"
  	;; 
	\?)
  	echo "Invalid option: -$OPTARG"
  	;;
	:)
  	echo "Option -$OPTARG requires an argument."
  	;;
  esac
done


echo -n "[Info] Checking AWS CLI v2 installation: "
aws --version 
if [ $? -ne 0 ]; then
  echo "[Error] AWS CLI v2 is not installed or not available in PATH. Please install AWS CLI v2 to use this script." 
  exit 1
fi  
echo -n "[Info] Checking AWS Session Manager Plugin installation: "
/usr/local/sessionmanagerplugin/bin/session-manager-plugin --version  || echo "[Error] AWS Session Manager Plugin is not installed or not available in PATH. Please install Session Manager Plugin to use this script." 

echo "[Info] Connecting to the '${RDS}:${REMOTE_PORT}' in the '${REGION}' AWS region"
echo "[Info] Port forward with profile '${AWS_PROFILE}' to the port '${LOCAL_PORT}'"

# Trap Ctrl+C (SIGINT) to exit gracefully
ctrl_c() {
        echo "[Info] Stopping exectution, 'Ctrl + C' caught. Exiting..."
        exit 0
}        

exit_handler() {
        echo "[Info] Termination signal caught. Exiting..."
        exit 0
}

trap ctrl_c INT
trap exit_handler SIGTERM


# Bash function for connection
connection() {
  echo "[INFO] Starting SSM session"
  aws ssm start-session \
    --region "${6}" \
    --target "${3}" \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters host="${2}",portNumber="${4}",localPortNumber="${5}" \
    --profile "$1"
  echo "[Info] Port forwarding session has been closed/terminated or not able to connect."
}
echo "[Info] Getting SSO token ..."	
aws sso login --profile "${AWS_PROFILE}" || echo "[Error] Not able to login via SSO"
echo -n "[Info] Waiting for running state of the jump/bastion host '${BASTION_HOST}' "
INSTANCE_STATE=$(aws ec2 describe-instances --instance-ids "$BASTION_HOST" --output text --query 'Reservations[*].Instances[*].State.Name' --region "$REGION" --profile "$AWS_PROFILE")


until [[ "$INSTANCE_STATE" == "running" ]]; do 
  INSTANCE_STATE=$(aws ec2 describe-instances --instance-ids "$BASTION_HOST" --output text \
	--query 'Reservations[*].Instances[*].State.Name' --region "$REGION" --profile "$AWS_PROFILE")
  if  [[ "$INSTANCE_STATE" != "running" ]]; then
    echo -n '.' 
    sleep $BASTION_CHECK_SLEEP_INTERVAL
  fi
done
echo ''
echo "[Info] Jump/bastion host '${BASTION_HOST}' is in the running sate"
echo "[Info] Starting port forwarding connection"

while :
do
  connection "$AWS_PROFILE" "$RDS" "$BASTION_HOST" "$REMOTE_PORT" "$LOCAL_PORT" "$REGION" || \
    echo "[Error] Can't provide port forwarding with a SSH tunnel via AWS SSM" && \
    echo "[INFO] Getting SSO token ..." &&	\
    aws sso login --profile "${AWS_PROFILE}"
done  
