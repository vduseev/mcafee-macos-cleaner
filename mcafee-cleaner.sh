#!/usr/bin/env bash

#
#
STEP_REMOVE_INSTALLATION="Removing McAfee"
STEP_STOP_SERVICES="Stopping McAfee services"
STEP_REMOVE_SERVICES="Removing McAfee services"
STEP_KILL_PROCESSES="Killing all remaining McAfee processes"
STEP_REMOVE_USER="Removing McAfee user and group from the system"
STEP_REMOVE_DIRS="Removing McAfee directories"
STEP_REMOVE_FILES="Removing McAfee files"
STEP_UNLOAD_KEXTS="Unloading McAfee kernel extensions"
STEP_PREVENT_INSTALLATION="Preventing McAfee from installing itself again"
STEP_RECREATE_DIRS="Recreate McAfee directory structure and make it immutable"
STEP_COUNTER=1

MCAFEE_DIR_PATHS=(
  "/usr/local/McAfee/"
  "/Library/Application Support/McAfee/"
  "/Library/McAfee/"
  "/var/McAfee/"
  "/etc/ma.d"
  "/etc/cma.d/"
  "/Library/StartupItems/ma"
  "/Library/StartupItems/cma"
  "/Applications/McAfee Endpoint Security for Mac.app/"
)

MCAFEE_FILE_GLOBS=(
  "/private/var/db/receipts/com.mcafee*"
  "/private/var/log/McAfeeSecurity.log*"
  "/Library/LaunchDaemons/com.mcafee*"
  "/etc/ma.conf"
)

MCAFEE_SERVICES=(
  "com.mcafee.menulet"
  "com.mcafee.reporter"
  "com.mcafee.virusscan.fmpd"
  "com.mcafee.ssm.ScanManager"
  "com.mcafee.virusscan.ssm.ScanFactory"
  "com.mcafee.ssm.Eupdate"
  "com.mcafee.agent.macompat"
  "com.mcafee.agent.ma"
  "com.mcafee.agent.macmn"
)

MCAFEE_KEXTS=(
  "com.McAfee.FMPSysCore"
  "com.McAfee.AVKext"
  "com.McAfee.FileCore"
)

MCAFEE_USER="mfe"
MCAFEE_GROUP="mfe"

main() {
  echo "$STEP_REMOVE_INSTALLATION"

  report_step "$STEP_STOP_SERVICES"
  launchctl_action_on_services "stop"

  report_step "$STEP_REMOVE_SERVICES"
  launchctl_action_on_services "remove"

  report_step "$STEP_KILL_PROCESSES"
  pkill -i -f mcafee

  report_step "$STEP_REMOVE_USER"
  delete_user "$MCAFEE_USER" "$MCAFEE_GROUP"
  
  report_step "$STEP_REMOVE_DIRS"
  remove_dirs
  
  report_step "$STEP_REMOVE_FILES"
  remove_files
  
  report_step "$STEP_UNLOAD_KEXTS"
  unload_kexts

  echo ""
  echo "$STEP_PREVENT_INSTALLATION"
  report_step "$STEP_RECREATE_DIRS"
  create_immutable_dirs
}

report_step() {
  local __step="$1"
  echo "${STEP_COUNTER}. ${__step} ..."
  STEP_COUNTER=$((STEP_COUNTER+1))
}

launchctl_action_on_services() {
  local __action="$1"
  for i in "${MCAFEE_SERVICES[@]}"; do
    launchctl "${__action}" "${i}"
  done
}

delete_user() {
  local __user="$1"
  local __group="$2"
  # Ignore errors if user already deleted
  dscl . -delete "/Users/${__user}" &> /dev/null
  dscl . -delete "/groups/${__group}" &> /dev/null
}

remove_dirs() {
  for i in "${MCAFEE_DIR_PATHS[@]}"; do
    echo "${i}"
    ls -laO "${i}"
    # Check if the directory is already marked by us as immutable
    if [[ ! $(ls -laO "${i}" | grep schg | grep -c uchg) -ge 1 ]]; then
      rm -rf "${i}"
    fi
  done
}

remove_files() {
  for i in "${MCAFEE_FILE_GLOBS[@]}"; do
    rm -rf "${i}"
  done
}


create_immutable_dirs() {
  for i in "${MCAFEE_DIR_PATHS[@]}"; do
    # Create dir
    mkdir -p "${i}"
    # Make it immutable by user 
    chflags -R uchg "${i}"
    # Make it immutable to system
    chflags -R schg "${i}"
  done
}

unload_kexts() {
  for i in "${MCAFEE_KEXTS[@]}"; do
    kextunload -b "${i}" &> /dev/null
  done
}

# Execute
main

