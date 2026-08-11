# mac-dev-setup
This document describes how to set up a development environment on a new MacBook or iMac. The setup includes:

1. System Preferences
2. Xcode Command Line Tools
3. Homebrew
4. Git
5. Oh My Zsh

## Run Setup

The setup is a single idempotent bash script (no Terraform or state required):

```bash
bash setup.sh
```

Installed components can be verified individually (pyenv, oh-my-posh, etc.); re-running the script is safe and skips completed steps.

## Font Validation

To validate the Nerd Font installation, run:
```bash
echo "\ue62b" # This should display a symbol if the Nerd Font is working
```

## Change Default Font in iTerm

1. Open iTerm (Command + ,)
2. Go to Profile -> Font -> FireCode Nerd Font Propo
