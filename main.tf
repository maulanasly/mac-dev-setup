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

# Install additional dev tools
resource "null_resource" "install_dev_tools" {
  depends_on = [null_resource.install_homebrew]
  provisioner "local-exec" {
    command = "brew install git neovim tmux oh-my-posh zsh-autosuggestions zsh-syntax-highlighting"
  }
}

# Configure ~/.zshrc for pyenv, oh-my-posh, and auto-completion
resource "null_resource" "setup_zshrc" {
  provisioner "local-exec" {
    command = <<EOT
      touch ~/.zshrc
      echo '\n# Pyenv setup' >> ~/.zshrc
      echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.zshrc
      echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
      echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc

      echo '\n# Oh My Posh setup' >> ~/.zshrc
      echo 'if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then' >> ~/.zshrc
      echo '  eval "$(oh-my-posh init zsh)"' >> ~/.zshrc
      echo 'fi' >> ~/.zshrc
      echo 'eval "$(oh-my-posh init zsh --config ~/.poshthemes/M365Princess.omp.json)"' >> ~/.zshrc

      echo '\n# Zsh plugins' >> ~/.zshrc
      echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> ~/.zshrc
      echo 'source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc
      echo 'source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc

      echo '\n# Auto-completion setup' >> ~/.zshrc
      echo 'autoload -U compinit' >> ~/.zshrc
      echo 'compinit' >> ~/.zshrc
      echo 'source ~/.oh-my-posh-completion.zsh' >> ~/.zshrc
    EOT
  }
}
