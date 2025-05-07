#!/bin/bash
# FILE: install.sh
# DESCRIPTION: Master setup script for nvim-docker
# AUTHOR: Thomas Patton

# install directory


show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [CONFIG GIT REPO]

Neovim instalation script.

OPTIONS:
  -p    Sets the instalation root directory. (defaults to /root)
  -h    Show this help message.

EOF
}

while getopts ":p:h" opt; do
    case ${opt} in
    p)
        INSTALL_DIR="${OPTARG}"
        ;;
    h)
        show_help;
        exit 0;
        ;;
    esac
done
shift $((OPTIND-1))


INSTALL_DIR="${INSTALL_DIR:-/root}"
NEOVIM_DIR=nvim-linux-x86_64
NEOVIM_INSTALLER="https://github.com/neovim/neovim/releases/download/v0.11.1/${NEOVIM_DIR}.tar.gz"

echo "Running Docker container setup..."

# Update XDG_CONFIG_HOME
export XDG_CONFIG_HOME="${INSTALL_DIR}/.config"
export XDG_DATA_HOME="${INSTALL_DIR}/.local/share"
export XDG_STATE_HOME="${INSTALL_DIR}/.local/state"
export TERM="xterm-256color"
export DISPLAY=":0"

cd "$INSTALL_DIR"
rm -rf "${XDG_CONFIG_HOME}"
sudo apt-get update

# XCLIP 
sudo apt-get install -y xclip

# NPM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="${XDG_CONFIG_HOME}/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
nvm install 16.15.1

# NEOVIM
wget ${NEOVIM_INSTALLER}
tar xzvf ${NEOVIM_DIR}.tar.gz
sudo ln -s "${INSTALL_DIR}/${NEOVIM_DIR}/bin/nvim" /usr/local/bin/nvim
sudo apt-get install -y python3-venv

# RIPGREP
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
sudo apt-get install "./ripgrep_13.0.0_amd64.deb"

# FD
curl -LO https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-musl_10.2.0_amd64.deb
sudo apt-get install "./fd-musl_10.2.0_amd64.deb"

# Git Repository (provided as an argument)
if [ -n "$1" ]; then
    git clone "$1" "${XDG_CONFIG_HOME}/nvim" 
else
    echo "Git repository URL not provided, proceeding without"
fi

# exit
cd ~
