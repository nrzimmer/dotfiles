# Keep PATH entries unique, even when shells nest and re-source this file
typeset -U path PATH

. "$HOME/.cargo/env"

# pipx / user-local binaries (merged from former .zprofile)
export PATH="$PATH:$HOME/.local/bin"

# sdkman-managed maven (installed for careos; non-interactive shells don't source .zshrc's sdkman-init.sh)
export PATH="$PATH:$HOME/.sdkman/candidates/maven/current/bin"
