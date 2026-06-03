# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
export BREW="/opt/homebrew/bin"
export PATH="$BREW:$PATH"

ZSH_THEME="powerlevel10k/powerlevel10k"

####################################
####            Alias           ####
####################################

alias python='/opt/homebrew/bin/python3'
alias ll='colorls -lA --sd --group-directories-first'
alias ls='colorls --dark --sort-dirs --report'
alias lc='colorls --tree --light'
alias gs="git status"
alias ga="git add ."
alias gp="git push"
alias gc="git commit -m"
alias gcz="git-cz"
alias gpl="git pull"
alias gb="git branch"
alias gck="git checkout"
alias gckn="git checkout -b"
alias cls="clear"
alias docc="docker container"
alias doci="docker image"
alias gw="git switch"
alias clean:branch="git for-each-ref --format '%(refname:short)' refs/heads | grep -v 'master\|main' | xargs git branch -D"

bindkey "[D" backward-word
bindkey "[C" forward-word
bindkey "^[a" beginning-of-line
bindkey "^[e" end-of-line

####################################
####        Environment         ####
####################################

eval "$(direnv hook zsh)"

export AWS_REGION=us-west-2

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

####################################
####           Source           ####
####################################

source $ZSH/oh-my-zsh.sh

####################################
####            asdf            ####
####################################

. /opt/homebrew/opt/asdf/libexec/asdf.sh

export PATH="$PATH:$HOME/.local/bin"
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

####################################
####             bun            ####
####################################

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

alias claude-mem='"$HOME"/.bun/bin/bun "$HOME/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'
