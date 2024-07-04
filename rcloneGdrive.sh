#!/bin/bash

# Created by Chris Mariano (cdm436@nyu.edu)
# Title: Automate rclone copy for gdrive
# License: MIT License

# Define the port to use for the authentication process
AUTH_PORT=53682
TIMEOUT=300  # Timeout in seconds (5 minutes)

# Function to display GUI instructions
show_instructions() {
  osascript <<EOF
    tell application "System Events"
      activate
      display dialog "NYUAD Rclone-Google Drive File Transfer Utility

1. Click \"Proceed\" to run this script and and type your mac login password if prompted.
2. Next a browser window will open for Google authentication.
3. Once authenticated, you will be prompted to allow RClone App for permission. Click \"Allow\".
4. WAIT FOR THE WINDOW to select whether to copy or move files.
5. Finally, select the destination for the transfer.

Note: This is beta software. Use at your own risk. Contact NYUAD IT if you have any questions.

Click \"Proceed\" to continue." with title "Rclone Setup Instructions" buttons {"Proceed"} default button "Proceed"
    end tell
EOF
}

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
  local start_time=$(date +%s)
  local elapsed_time=0

  # Check if rclone config already exists and remove it if necessary
  if rclone listremotes | grep -q "^mygoogledrive:"; then
    echo "Removing existing mygoogledrive configuration..."
    rclone config delete mygoogledrive
  fi

  echo "Configuring rclone with Google Drive..."
  echo "This will open a browser window for authentication."

  ensure_port_free $AUTH_PORT

  # Loop until timeout or successful configuration
  while [ $elapsed_time -lt $TIMEOUT ]; do
    rclone config create mygoogledrive drive --rc-addr=127.0.0.1:$AUTH_PORT &> /dev/null
    if [ $? -eq 0 ]; then
      echo "rclone configuration completed."
      return 0
    fi
    sleep 5
    elapsed_time=$(( $(date +%s) - $start_time ))
  done

  echo "rclone configuration timed out after $TIMEOUT seconds."
  exit 1
}

# Function to close any open browser pages with http://127.0.0.1:53682/
close_browser_pages() {
  osascript <<EOF
    tell application "Google Chrome"
      set windowList to every window
      repeat with aWindow in windowList
        set tabList to every tab of aWindow
        repeat with atab in tabList
          if URL of atab contains "http://127.0.0.1:$AUTH_PORT/" then
            close atab
          end if
        end repeat
      end repeat
    end tell
    tell application "Safari"
      set windowList to every window
      repeat with aWindow in windowList
        set tabList to every tab of aWindow
        repeat with atab in tabList
          if URL of atab contains "http://127.0.0.1:$AUTH_PORT/" then
            close atab
          end if
        end repeat
      end repeat
    end tell
EOF
}

# Function to prompt the user for the destination directory using AppleScript
select_destination() {
  local dest_dir
  dest_dir=$(osascript <<EOF
    tell application "System Events"
      activate
      set theFolder to choose folder with prompt "Select Destination Directory for Google Drive"
      return POSIX path of theFolder
    end tell
EOF
  )
  echo "$dest_dir"
}

# Function to copy or move the entire Google Drive to a selected location
transfer_drive() {
  local action=$1
  local dest_dir
  dest_dir=$(select_destination)

  if [ -z "$dest_dir" ]; then
    echo "No destination directory selected. Exiting."
    exit 1
  fi

  echo "${action}ing Google Drive to $dest_dir..."
  osascript <<EOF
    tell application "Terminal"
      do script "rclone ${action} mygoogledrive: \"$dest_dir\" --progress"
      activate
    end tell
EOF
}

# Main script
show_instructions

check_homebrew
install_tools
configure_rclone

if rclone lsd mygoogledrive: &> /dev/null; then
  close_browser_pages
  choice=$(osascript <<EOF
    tell application "System Events"
      activate
      set theChoice to button returned of (display dialog "Google Drive is ready, select tranfer mode" buttons {"Copy", "Move"} default button "Copy")
      return theChoice
    end tell
EOF
  )
  case $choice in
    "Copy") transfer_drive "copy" ;;
    "Move") transfer_drive "move" ;;
    *) echo "Invalid choice. Exiting." ; exit 1 ;;
  esac
else
  echo "Failed to connect to Google Drive. Exiting."
  exit 1
fi

echo "Setup complete."
