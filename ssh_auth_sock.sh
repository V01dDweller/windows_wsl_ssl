#!/bin/bash

# Append the lines below to ~/.bashrc

WINDOWS_USER=$(powershell.exe -c echo '$env:UserName' | sed 's/ //')

export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock

ss -a | grep -q $SSH_AUTH_SOCK
if [ $? -ne 0 ]; then
  rm -f $SSH_AUTH_SOCK
  npiperelaypath="/mnt/c/Users/$WINDOWS_USER/.local/bin"
  (setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"$npiperelaypath/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
fi
