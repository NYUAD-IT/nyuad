#!/bin/bash

# Created by Chris Mariano (cdm436@nyu.edu)
# Title: Automate rclone copy for gdrive
# License: MIT License

# Define the port to use for the authentication process
AUTH_PORT=53682
TIMEOUT=300  # Timeout in seconds (5 minutes)

# Function to check if Homebrew is installed
check_homebrew() {
  if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Ensure brew command is in the PATH
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo "Homebrew is already installed."
  fi
}

# Function to install rclone and coreutils
install_tools() {
  if ! brew list rclone &> /dev/null; then
    echo "Installing rclone..."
    brew install rclone
  else
    echo "rclone is already installed."
  fi

  if ! brew list coreutils &> /dev/null; then
    echo "Installing coreutils..."
    brew install coreutils
  else
    echo "coreutils is already installed."
  fi
}

# Function to check if a port is in use and stop the process using it
ensure_port_free() {
  local port=$1
  if lsof -i:$port &> /dev/null; then
    echo "Port $port is in use. Stopping the process using it..."
    lsof -ti:$port | xargs kill -9
  else
    echo "Port $port is free."
  fi
}

# Function to configure rclone with Google Drive
configure_rclone() {
  # Check if rclone config already exists and remove it if necessary
  if rclone listremotes | grep -q "^nyuad_gdrive:"; then
    echo "Removing existing nyuad_gdrive configuration..."
    rclone config delete nyuad_gdrive
  fi

  echo "Configuring rclone with Google Drive..."
  echo "This will open a browser window for authentication."

  ensure_port_free $AUTH_PORT

  gtimeout $TIMEOUT rclone config create nyuad_gdrive drive --rc-addr=127.0.0.1:$AUTH_PORT

  if [ $? -eq 124 ]; then
    echo "rclone configuration timed out after $TIMEOUT seconds."
    exit 1
  fi
}

# Function to prompt the user for the destination directory using AppleScript
select_destination() {
  local dest_dir
  dest_dir=$(osascript <<EOF
    tell application "System Events"
      activate
      set theFolder to choose folder with prompt "Select Destination Directory for Google Drive Copy"
      return POSIX path of theFolder
    end tell
EOF
  )
  echo "$dest_dir"
}

# Function to copy the entire Google Drive to a selected location
copy_drive() {
  local dest_dir
  dest_dir=$(select_destination)

  if [ -z "$dest_dir" ]; then
    echo "No destination directory selected. Exiting."
    exit 1
  fi

  echo "Copying Google Drive to $dest_dir..."
  osascript <<EOF
    tell application "Terminal"
      do script "rclone copy nyuad_gdrive: \"$dest_dir\" --progress --drive-acknowledge-abuse"
      activate
    end tell
EOF
}

# Main script
check_homebrew
install_tools
configure_rclone

if rclone lsd nyuad_gdrive: &> /dev/null; then
  copy_drive
else
  echo "Failed to connect to Google Drive. Exiting."
  exit 1
fi

echo "Setup complete."
