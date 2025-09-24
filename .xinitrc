eval $(gnome-keyring-daemon --start)
export SSH_AUTH_SOCK
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
exec i3
