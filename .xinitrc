eval $(gnome-keyring-daemon --start)
export SSH_AUTH_SOCK

# Load shell-independent session environment (zsh login shells don't read these)
[ -f ~/.profile ] && . ~/.profile
[ -f ~/.xprofile ] && . ~/.xprofile

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
exec i3
