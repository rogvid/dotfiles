# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH_CONFIG="$HOME/zsh.d"
export ZSH="$HOME/.oh-my-zsh"
export EDITOR='nvim'

unset EXTRA_PATHS
EXTRA_PATHS = ()
echo $EXTRA_PATHS


# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""

# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    zsh-autosuggestions
    you-should-use
)

source $ZSH/oh-my-zsh.sh

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

# Load custom paths
if [ -f $ZSH_CONFIG/.zsh_paths ]; then while IFS= read -r line; do if [[ ! $line = \#* ]]; then EXTRA_PATHS+=("$line"); elif [[ $line == *"deprecated"* ]]; then echo "Warning: $line"; fi; done < $ZSH_CONFIG/.zsh_paths; fi

# Load aliases
if [ -f $ZSH_CONFIG/.zsh_aliases ]; then . $ZSH_CONFIG/.zsh_aliases; fi

# Load functions
if [ -f $ZSH_CONFIG/.zsh_functions ]; then . $ZSH_CONFIG/.zsh_functions; fi

# Load scripts
# if [ -d $ZSH_CONFIG/.zsh_scripts ]; then export PATH=$ZSH_CONFIG/.zsh_scripts/:$PATH; fi
if [ -d $ZSH_CONFIG/.zsh_scripts ]; then EXTRA_PATHS+=("$ZSH_CONFIG/.zsh_scripts/"); fi

# Load custom keymaps
if [ -f $ZSH_CONFIG/.zsh_keymaps ]; then . $ZSH_CONFIG/.zsh_keymaps; fi

# Load custom settings
if [ -f $ZSH_CONFIG/.zsh_configurations ]; then . $ZSH_CONFIG/.zsh_configurations; fi


# Add all extra paths 
pathappend $EXTRA_PATHS

# Enable zoxide
eval "$(zoxide init zsh)"

# Enable fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# mapfile -t myArray < file.txt

# Enable direnv
eval "$(direnv hook zsh)"

# Setting up pixi
# Install or update with `curl -fsSL https://pixi.sh/install.sh | bash`
eval "$(pixi completion --shell zsh)"

