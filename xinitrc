export LANG=de_DE.UTF-8
xrdb ~/.Xresources
urxvtd -q -f -o &
# setxkbmap -layout de
#eval $(ssh-agent)
#export XSESSION_ID=$(uuidgen)
exec awesome
#exec xfce
#exec Lumina-DE
#exec ck-launch-session gnome-session
#exec i3
