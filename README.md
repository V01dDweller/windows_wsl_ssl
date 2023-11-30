# windows_wsl_ssh

This project makes ssh keys loaded in Windows 11 available to WSL2 instances
using:

* [KeePassXC](https://keepassxc.org/) for Windows
* The [npiperelay](https://github.com/jstarks/npiperelay) project
* The [socat](http://www.dest-unreach.org/socat/) Linux command


Credit: https://code.mendhak.com/wsl2-keepassxc-ssh

---
## OpenSSH

1. Download OpenSSH 8.9.1.0 Beta for Windows (user PowerShell and winget):

```powershell
winget install Microsoft.OpenSSH.Beta --version 8.9.1.0
```

2. Add the OpenSSH 8.9.1.0 Beta to be first in your PATH:

Either use:

```powershell
cmd /c set PATH=C:\Program Files\OpenSSH;%PATH%
```

or: `Start` -> `View Advanced System Settings` -> `Environment Variables` the add 

```
C:\Program Files\OpenSSH
```

**Note:** Be sure to move this entry to the top so that is found before the older version that is bundled with Windows.


## KeePassXC

1. Download and install [KeePassXC](https://keepassxc.org/) for Windows.
2. Create your first password database
3. Add one or more password-protected ssh key entries, attach a public and private key to each one.
4. Edit each entry:
   - click `SSH Agent` in the left navigation
   - check `Add key to agent when database is opened/unlocked`,
   - Select the Private key attachment

5. Click `[ OK ]`
6. Open KeePassXC Settings (`Tools` -> `Settings` or `CTRL-,`)
7. Select `SSH Agent` in the left nagivation
8. Check [ ] Enable SSH Agent integration
9. Select `Use OpenSSH`
10. Click [OK]
11. Confirm ssh key(s) are loaded in PowerShell:

```
PS C:\> ssh-add -l
3072 SHA256:KQZ/TqRRRnQ133em+qwer'kWET834DKLwtTT00qqHOQ jdoe@jammy01 (RSA)
```


## WSL2

### Step 1

Run the script `npiperelay.sh`. This will:

1. Create `%USERPROFILE%\.local\bin`
2. Download and extract `npiperelay.exe` to that directory
3. Install the `socat` command for Ubuntu

## Step 2

Append the lines below to `~/.bashrc`:

```shell
WINDOWS_USER=$(powershell.exe -c echo '$env:UserName' | sed 's/ //')
export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock

ss -a | grep -q $SSH_AUTH_SOCK
if [ $? -ne 0 ]; then
  rm -f $SSH_AUTH_SOCK
  npiperelaypath="/mnt/c/Users/$WINDOWS_USER/.local/bin"
  (setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"$npiperelaypath/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
fi
```

### Step 3

Source `~/.bashrc`

[modeline]: # ( vim: set number relativenumber textwidth=78 colorcolumn=80: )


## Validate

Use the command `ssh-add -l` to list the available keys. If all went well, each key should be listed, e.g.:

```
bash-5.1$ ssh-add -l
3072 SHA256:KQZ/TqRRRnQ133em+qwer'kWET834DKLwtTT00qqHOQ jdoe@jammy01 (RSA)
```

## Troublehooting

No keys listed after `ssh-add -l`?

* Is KeePassXC running?
* Is a database loaded and unlocked?
* Does the SSH key entry have a public key attached and selected?
* Is `[ ] Add key to agent when database is opended/unlocked` checked?
* Is `[ ] Enable SSH Agent integration` checked in KeePassXC settings?
* Is the `socat` command/package installed in WSL2 Ubuntu?
