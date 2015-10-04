# $FreeBSD: release/10.0.0/share/skel/dot.profile 199243 2009-11-13 05:54:55Z ed $
#
# .profile - Bourne Shell startup script for login shells
#
# see also sh(1), environ(7).
#

# remove /usr/games if you want
PATH=$HOME/.local/bin:$HOME/.bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin; export PATH

# Setting TERM is normally done through /etc/ttys.  Do only override
# if you're sure that you'll never log in via telnet or xterm or a
# serial line.
# TERM=xterm-256color; 	export TERM

BLOCKSIZE=K;	export BLOCKSIZE
EDITOR=vi;  export EDITOR
PAGER='less -R';  	export PAGER

# set ENV to a file invoked each time sh is started for interactive use.
# ENV=$HOME/.shrc; export ENV

if [ -x /usr/games/fortune ] ; then /usr/games/fortune freebsd-tips ; fi

# Personal
CLICOLOR="YES"; export CLICOLOR
LSCOLORS="ExGxFxdxCxDxDxhbadExEx"; export LSCOLORS
BROWSER=/usr/local/bin/conkeror; export BROWSER

fetchmail -s &
