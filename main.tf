terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "null" {}

# Install Homebrew if not installed
resource "null_resource" "install_homebrew" {
  provisioner "local-exec" {
    command = <<EOT
      if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
    EOT
  }
}

# Install pyenv, pyenv-virtualenv, and dependencies
resource "null_resource" "install_pyenv" {
  depends_on = [null_resource.install_homebrew]
  provisioner "local-exec" {
    command = <<EOT
      brew install pyenv
      brew install pyenv-virtualenv
      brew install openssl readline sqlite3 xz zlib
    EOT
  }
}

# Install Python versions via pyenv
resource "null_resource" "install_python" {
  depends_on = [null_resource.install_pyenv]
  provisioner "local-exec" {
    command = <<EOT
      eval "$(pyenv init --path)"
      pyenv install 3.12.0
      pyenv install 3.10.12
      pyenv global 3.12.0
    EOT
  }
}

# Install fonts and terminal tools first
resource "null_resource" "install_fonts_and_tools" {
  depends_on = [null_resource.install_homebrew]
  provisioner "local-exec" {
    command = <<EOT
      brew tap homebrew/cask-fonts
      brew install --cask font-fira-code-nerd-font
      brew install oh-my-posh zsh-autosuggestions zsh-syntax-highlighting
    EOT
  }
}

# Configure ~/.zshrc for pyenv, oh-my-posh, and auto-completion
resource "null_resource" "setup_zshrc" {
  provisioner "local-exec" {
    command = <<EOT
      # Clear existing .zshrc content
      echo '' > ~/.zshrc

      # Add Oh My Posh conditional setup
      echo 'if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then' >> ~/.zshrc
      echo '  eval "$(oh-my-posh init zsh)"' >> ~/.zshrc
      echo 'fi' >> ~/.zshrc
      echo '' >> ~/.zshrc

      # Add plugins declaration
      echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> ~/.zshrc
      echo '' >> ~/.zshrc

      # Add Oh My Posh theme configuration
      echo 'eval "$(oh-my-posh init zsh --config ~/.poshthemes/M365Princess.omp.json)"' >> ~/.zshrc
      echo '' >> ~/.zshrc

      # Add auto-completion setup
      echo 'autoload -U compinit' >> ~/.zshrc
      echo 'compinit' >> ~/.zshrc
      echo 'source ~/.oh-my-posh-completion.zsh' >> ~/.zshrc
      echo '' >> ~/.zshrc

      # Add Pyenv setup
      echo '# Pyenv setup' >> ~/.zshrc
      echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.zshrc
      echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
      echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc
      echo '' >> ~/.zshrc

      # Add Oh My Posh setup again (as per your current .zshrc)
      echo '# Oh My Posh setup' >> ~/.zshrc
      echo 'if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then' >> ~/.zshrc
      echo '  eval "$(oh-my-posh init zsh)"' >> ~/.zshrc
      echo 'fi' >> ~/.zshrc
      echo 'eval "$(oh-my-posh init zsh --config ~/.poshthemes/M365Princess.omp.json)"' >> ~/.zshrc
      echo '' >> ~/.zshrc

      # Add Zsh plugins
      echo '# Zsh plugins' >> ~/.zshrc
      echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> ~/.zshrc
      echo 'source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc
      echo 'source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc
      echo '' >> ~/.zshrc

      # Add Auto-completion setup
      echo '# Auto-completion setup' >> ~/.zshrc
      echo 'autoload -U compinit' >> ~/.zshrc
      echo 'compinit' >> ~/.zshrc
      echo 'source ~/.oh-my-posh-completion.zsh' >> ~/.zshrc
      echo '' >> ~/.zshrc

      # Add ZSH Highlight Highlighters directory
      echo 'export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/opt/homebrew/share/zsh-syntax-highlighting/highlighters' >> ~/.zshrc
    EOT
  }
}
