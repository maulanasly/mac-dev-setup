#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { printf "${GREEN}[setup]${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}[setup]${NC} %s\n" "$1"; }

step() { printf "\n${GREEN}==>${NC} %s\n" "$1"; }

step "Xcode Command Line Tools"
if xcode-select -p &> /dev/null; then
  info "Xcode CLT already installed"
else
  warn "Installing Xcode Command Line Tools (accept the prompt)…"
  xcode-select --install
  until xcode-select -p &> /dev/null; do
    sleep 5
  done
  info "Xcode CLT installed"
fi

step "Homebrew"
if command -v brew &> /dev/null; then
  info "Homebrew already installed"
else
  warn "Installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  info "Homebrew installed"
fi

step "pyenv and build dependencies"
brew install pyenv pyenv-virtualenv openssl readline sqlite3 xz zlib

step "Python versions (3.12.0, 3.10.12)"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

if ! pyenv versions --bare | grep -qx "3.12.0"; then
  pyenv install 3.12.0
else
  info "Python 3.12.0 already installed"
fi

if ! pyenv versions --bare | grep -qx "3.10.12"; then
  pyenv install 3.10.12
else
  info "Python 3.10.12 already installed"
fi

pyenv global 3.12.0

step "Fonts and terminal tools"
brew tap homebrew/cask-fonts
brew uninstall --cask font-fira-code-nerd-font || true
brew install --cask font-fira-code-nerd-font
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

step "Configure ~/.zshrc"
cat > ~/.zshrc << 'EOF'
# Pyenv setup
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Oh My Posh
eval "$(oh-my-posh init zsh --config ~/.poshthemes/M365Princess.omp.json)"

# Auto-completion
autoload -U compinit
compinit
[ -f ~/.oh-my-posh-completion.zsh ] && source ~/.oh-my-posh-completion.zsh

# Zsh plugins
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/opt/homebrew/share/zsh-syntax-highlighting/highlighters
EOF

step "Done! Restart your terminal or run: source ~/.zshrc"