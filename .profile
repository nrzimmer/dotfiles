. "$HOME/.cargo/env"

# Fedora's GDM leaks XDG_SESSION_TYPE=wayland into X sessions (i3 runs on Xorg).
# Force x11 so Qt/portal apps (e.g. Spectacle) use the X11 grabber instead of the
# GNOME desktop portal, which can't capture under i3.
export XDG_SESSION_TYPE=x11

# KDE/Qt apps (e.g. Spectacle, kcalc) get Breeze + the BreezeDark color scheme from
# ~/.config/kdeglobals via the KDE platform theme. Under i3 (XDG_CURRENT_DESKTOP=i3)
# Qt won't auto-load it, so select it explicitly. environment.d is not reliably
# loaded for GDM X sessions, so set it here where the X session sources it.
export QT_QPA_PLATFORMTHEME=kde

export GTK_THEME=Adwaita:dark

[ -f "/home/zimmer/.ghcup/env" ] && . "/home/zimmer/.ghcup/env" # ghcup-env
export _JAVA_OPTIONS=-Dawt.useSystemAAFontSettings=gasp
