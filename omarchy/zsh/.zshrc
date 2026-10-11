# Minimal zsh init for Omarchy.
# Ported from the old Arch setup (.zshrc): only oh-my-posh for now.
# History options, zinit plugins, completion styling, and aliases still live
# in the old .zshrc -- porting those is a follow-up.

# OH MY POSH (theme: ~/.config/ohmyposh/zen.toml)
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"
