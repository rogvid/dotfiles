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

# Add wisely, as too many plugins slow down shell startup.
plugins=(
    fzf-tab
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    you-should-use
)

source $ZSH/oh-my-zsh.sh

zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

#Star Ship
eval "$(starship init zsh)"

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


# Enable pyenv
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Enable direnv
eval "$(direnv hook zsh)"

# Enable navi
eval "$(navi widget zsh)"

# Setting up pixi
# Install or update with `curl -fsSL https://pixi.sh/install.sh | bash`
eval "$(pixi completion --shell zsh)"

# Set up atuin
eval "$(atuin init zsh --disable-up-arrow)"

# Set up brew
eval "$(brew shellenv)"

[ -s /home/flowteller/.nix-profile/etc/profile.d/nix.sh ] && . "/home/flowteller/.nix-profile/etc/profile.d/nix.sh";
[ -f "$HOME/.config/fabric/fabric-bootstrap.inc" ] && . "$HOME/.config/fabric/fabric-bootstrap.inc";
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh";
[ -s "$HOME/.nvm/bash_completion" ] && . "$HOME/.nvm/bash_completion";

# bun completions
[ -s "/home/flowteller/.local/share/reflex/bun/_bun" ] && source "/home/flowteller/.local/share/reflex/bun/_bun"

# bun
export BUN_INSTALL="$HOME/.local/share/reflex/bun"
export PATH="$BUN_INSTALL/bin:$PATH"
