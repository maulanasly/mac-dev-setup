# mac-dev-setup
This document describes how I set up my development environment on a new MacBook or iMac. We will set up the following:

1. System Preferences
2. Xcode Command Line Tools
3. Homebrew
4. Git
5. Oh My Zsh

### Setup terraform
1. Install terraform
```bash
brew install terraform
```
2. Verify the installation
```bash
terraform --version
```
3. Initialize terraform
```bash
terraform init
```
4. Run terraform
```bash
terraform apply
```
5. Destroy terraform
```bash
terraform destroy
```
6. Format terraform
```bash
terraform fmt
```
7. Validate terraform
```bash
terraform validate
```
8. Plan terraform
```bash
terraform plan
```

### font validation
```bash
echo "\ue62b" # This should display a symbol if the Nerd Font is working
```

### Change font default
1. Open iterm (Command + ,)
2. Profile -> Font -> FireCode Nerd Font Propo