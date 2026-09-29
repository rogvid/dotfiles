# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH_CONFIG="$HOME/zsh.d"
export ZSH="$HOME/.oh-my-zsh"
export EDITOR='nvim'

unsetopt no_match
unset EXTRA_PATHS
EXTRA_PATHS = ()

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""

# Load identities

# Add wisely, as too many plugins slow down shell startup.
plugins=(
    fzf-tab
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    you-should-use
)

# plugin configurations
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

source $ZSH/oh-my-zsh.sh

# Activate mise
eval "$(~/.local/bin/mise activate zsh)"

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Load paths to append to PATH from file
if [ -f $ZSH_CONFIG/.zsh_paths ]; then 
  while IFS= read -r line; do 
    if [[ ! $line = \#* ]]; then 
      EXTRA_PATHS+=("$line"); 
    elif [[ $line == *"deprecated"* ]]; then 
      echo "Warning: $line"; 
    fi; 
  done < $ZSH_CONFIG/.zsh_paths; 
fi

# Load aliases
[ -f $ZSH_CONFIG/.zsh_aliases ] && . $ZSH_CONFIG/.zsh_aliases;

# Load functions
[ -f $ZSH_CONFIG/.zsh_functions ] && . $ZSH_CONFIG/.zsh_functions;

# Load scripts
# if [ -d $ZSH_CONFIG/.zsh_scripts ]; then export PATH=$ZSH_CONFIG/.zsh_scripts/:$PATH; fi
[ -d $ZSH_CONFIG/.zsh_scripts ] && EXTRA_PATHS+=("$ZSH_CONFIG/.zsh_scripts/");

# Load custom keymaps
[ -f $ZSH_CONFIG/.zsh_keymaps ] && . $ZSH_CONFIG/.zsh_keymaps;

# Load custom settings
[ -f $ZSH_CONFIG/.zsh_configurations ] && . $ZSH_CONFIG/.zsh_configurations;


# Add all extra paths 
pathappend $EXTRA_PATHS

# Enable zoxide
eval "$(zoxide init zsh)"

# Enable fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
#
# Load custom fzf configurations
[ -f $ZSH_CONFIG/.fzf.config ] && . $ZSH_CONFIG/.fzf.config;

#Star Ship
eval "$(starship init zsh)"

# Enable direnv
eval "$(direnv hook zsh)"

# Set up atuin
eval "$(atuin init zsh --disable-up-arrow)"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [[ $(grep -i Microsoft /proc/version) ]]; then
  export ZED_ALLOW_EMULATED_GPU=1
  alias zed="WAYLAND_DISPLAY='' zed"

  # Every WSL distro shares one kernel, and another one resetting its binfmt
  # entries takes WSL's own with it: Windows programs then fail with "exec
  # format error", which breaks the SSH agent relay and the YubiKey attach
  # below. Re-registering needs root, so say how instead of failing quietly.
  if [[ ! -e /proc/sys/fs/binfmt_misc/WSLInterop && ! -e /proc/sys/fs/binfmt_misc/WSLInterop-late ]]; then
    print -u2 "WSL cannot run Windows programs (WSLInterop is not registered). Fix:"
    print -u2 "  echo ':WSLInterop:M::MZ::/init:PF' | sudo tee /proc/sys/fs/binfmt_misc/register >/dev/null"
  fi
  #
  # Forward Windows SSH agent to WSL2 via npiperelay
  export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
  if [[ ! -S "$SSH_AUTH_SOCK" ]] || ! ssh-add -l &>/dev/null; then
    rm -f "$SSH_AUTH_SOCK"
    (setsid socat UNIX-LISTEN:"$SSH_AUTH_SOCK",fork EXEC:"$HOME/.local/bin/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &>/dev/null &)
  fi

  # Attach the YubiKey (wsl/AttachYubikey.ps1) whenever it is not in WSL, so a
  # WSL or Windows restart needs no manual step. In the background, because it
  # goes through Windows and takes a few seconds, and at most once a minute
  # however many shells start. The last attempt's output is in the .log.
  () {
    local vendors=(/sys/bus/usb/devices/*/idVendor(N))
    (( ${#vendors} )) && grep -qsx 1050 $vendors && return
    local last="${XDG_RUNTIME_DIR:-/tmp}/attach-yubikey.last"
    [[ -e $last && -z $(find "$last" -mmin +1 2>/dev/null) ]] && return
    touch "$last"
    (setsid powershell.exe -NoProfile -ExecutionPolicy Bypass \
      -File "$(wslpath -w "$HOME/.dotfiles/wsl/AttachYubikey.ps1")" &>"${last%.last}.log" &)
  }
fi



# peon-ping quick controls
alias peon="bash /home/kvist/.claude/hooks/peon-ping/peon.sh"
[ -f /home/kvist/.claude/hooks/peon-ping/completions.bash ] && source /home/kvist/.claude/hooks/peon-ping/completions.bash
