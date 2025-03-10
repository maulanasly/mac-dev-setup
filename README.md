# mac-dev-setup
This document describes how to set up a development environment on a new MacBook or iMac. The setup includes:

1. System Preferences
2. Xcode Command Line Tools
3. Homebrew
4. Git
5. Oh My Zsh

## Setup Terraform

1. Install Terraform: `brew install terraform`
2. Verify installation: `terraform --version`
3. Initialize: `terraform init`
4. Apply configuration: `terraform apply`
5. Destroy resources: `terraform destroy`
6. Format code: `terraform fmt`
7. Validate configuration: `terraform validate`
8. Plan changes: `terraform plan`

## Font Validation

To validate the Nerd Font installation, run:
```bash
echo "\ue62b" # This should display a symbol if the Nerd Font is working
```

## Change Default Font in iTerm

1. Open iTerm (Command + ,)
2. Go to Profile -> Font -> FireCode Nerd Font Propo
