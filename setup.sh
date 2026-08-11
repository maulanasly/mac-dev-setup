#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { printf "${GREEN}[setup]${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}[setup]${NC} %s\n" "$1"; }
fail() { printf "${RED}[setup]${NC} %s\n" "$1"; exit 1; }
step() { printf "\n${GREEN}==>${NC} %s\n" "$1"; }

detect_platform() {
  case "$(uname -s)" in
    Darwin) PLATFORM=macos ;;
    Linux)  PLATFORM=linux ;;
    *) fail "Unsupported platform: $(uname -s)" ;;
  esac

  if [ "$PLATFORM" = linux ]; then
    if command -v apt-get &> /dev/null; then DISTRO=apt
    elif command -v dnf &> /dev/null; then DISTRO=dnf
    elif command -v pacman &> /dev/null; then DISTRO=pacman
    elif command -v apk &> /dev/null; then DISTRO=apk
    else fail "Unsupported Linux distribution (supports apt/dnf/pacman/apk)"; fi
  fi
}

install_xcode_clt() {
  if xcode-select -p &> /dev/null; then
    info "Xcode CLT already installed"
  else
    warn "Installing Xcode Command Line Tools (accept the prompt)…"
    xcode-select --install
    until xcode-select -p &> /dev/null; do sleep 5; done
    info "Xcode CLT installed"
  fi
}

install_native_prereqs() {
  case "$DISTRO" in
    apt)
      sudo apt-get update
      sudo apt-get install -y curl git build-essential unzip zsh
      ;;
    dnf)
      sudo dnf install -y curl git make automake gcc gcc-c++ unzip zsh procps-ng file
      ;;
    pacman)
      sudo pacman -S --noconfirm --needed base-devel curl git unzip zsh procps-ng file
      ;;
    apk)
      sudo apk add --no-cache curl git build-base unzip zsh procps file
      ;;
  esac
}

eval_brew() {
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  elif [ -x "$HOME/.linuxbrew/bin/brew" ]; then
    eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
  else
    fail "Homebrew installed but shellenv could not be evaluated"
  fi
}

install_homebrew() {
  if command -v brew &> /dev/null; then
    info "Homebrew already installed"
  else
    warn "Installing Homebrew…"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval_brew
    info "Homebrew installed"
  fi
}

install_pyenv() {
  brew install pyenv pyenv-virtualenv openssl readline sqlite3 xz zlib

  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"

  local py
  for py in 3.12.0 3.10.12; do
    if pyenv versions --bare | grep -qx "$py"; then
      info "Python $py already installed"
    else
      pyenv install "$py"
    fi
  done

  pyenv global 3.12.0
}

install_fonts() {
  if [ "$PLATFORM" = macos ]; then
    brew tap homebrew/cask-fonts
    brew uninstall --cask font-fira-code-nerd-font || true
    brew install --cask font-fira-code-nerd-font
  else
    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"
    if fc-list 2> /dev/null | grep -qi "FiraCodeNerdFont"; then
      info "FiraCode Nerd Font already installed"
    else
      warn "Downloading Fira Code Nerd Font…"
      curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip -o /tmp/FiraCode.zip
      unzip -oq /tmp/FiraCode.zip -d "$font_dir"
      rm /tmp/FiraCode.zip
      fc-cache -f "$font_dir" &> /dev/null || true
      info "Fira Code Nerd Font installed"
    fi
  fi
}

install_terminal_tools() {
  brew install oh-my-posh zsh-autosuggestions zsh-syntax-highlighting

  mkdir -p ~/.poshthemes
  if [ ! -f ~/.poshthemes/themes.zip ]; then
    curl -fsSL https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -o ~/.poshthemes/themes.zip
    unzip -oq ~/.poshthemes/themes.zip -d ~/.poshthemes
    chmod u+rw ~/.poshthemes/*.json
    rm ~/.poshthemes/themes.zip
  else
    info "oh-my-posh themes already present"
  fi

  curl -fsSL https://github.com/JanDeDobbeleer/oh-my-posh/raw/main/themes/M365Princess.omp.json -o ~/.poshthemes/M365Princess.omp.json

  if [ -f .oh-my-posh-completion.zsh ] && [ ! -f ~/.oh-my-posh-completion.zsh ]; then
    cp .oh-my-posh-completion.zsh ~/.oh-my-posh-completion.zsh
    chmod +r ~/.oh-my-posh-completion.zsh
  fi
}

write_zshrc() {
  local brew_prefix="$(brew --prefix)"

  cat > ~/.zshrc << EOF
# Pyenv setup
export PYENV_ROOT="\$HOME/.pyenv"
export PATH="\$PYENV_ROOT/bin:\$PATH"
eval "\$(pyenv init -)"
eval "\$(pyenv virtualenv-init -)"

# Oh My Posh
eval "\$(oh-my-posh init zsh --config ~/.poshthemes/M365Princess.omp.json)"

# Auto-completion
autoload -U compinit
compinit
[ -f ~/.oh-my-posh-completion.zsh ] && source ~/.oh-my-posh-completion.zsh

# Zsh plugins
if [ -f "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [ -f "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR="$brew_prefix/share/zsh-syntax-highlighting/highlighters"
EOF
}

detect_platform
info "Platform: $PLATFORM${DISTRO:+ ($DISTRO)}"

step "Xcode Command Line Tools / native prerequisites"
if [ "$PLATFORM" = macos ]; then
  install_xcode_clt
else
  install_native_prereqs
fi

step "Homebrew"
install_homebrew

step "pyenv and build dependencies"
install_pyenv

step "Fonts"
install_fonts

step "Terminal tools"
install_terminal_tools

step "Configure ~/.zshrc"
write_zshrc

step "Done! Restart your terminal or run: source ~/.zshrc"