ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/slatedust.omp.json)"

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab

# load completions
zinit cdreplay -q
autoload -Uz compinit && compinit


HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*'        fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'

bindkey '^[w' kill-region

pkg() {
  case "$1" in
    search)
      if [[ -z "$2" ]]; then
        echo "Usage: pkg search <term>"
        return 1
      fi
      yay -Q | grep -i "$2" | awk '{print $1}'
      return 0
      ;;
    list)
      yay -Q | awk '{print $1}'
      return 0
      ;;
    total)
      yay -Q | wc -l | awk '{print $1}'
      return 0
      ;;
  esac

  if [[ $# -eq 0 ]]; then
    echo "Usage: pkg <package-name> ..."
    echo "       pkg search <term>"
    echo "       pkg list"
    echo "       pkg total"
    return 1
  fi

  local to_install=()
  local already_installed=()

  for pkgname in "$@"; do
    if ! yay -Si "$pkgname" &>/dev/null; then
      echo "❌ Package '$pkgname' not found"
      continue
    fi
    if yay -Q "$pkgname" &>/dev/null; then
      already_installed+=("$pkgname")
    else
      to_install+=("$pkgname")
    fi
  done

  if [[ ${#to_install[@]} -gt 0 ]]; then
    echo "📦 Installing: ${to_install[*]}..."
    yay -S "${to_install[@]}"
  fi

  for pkgname in "${already_installed[@]}"; do
    echo -e "\n📦 $pkgname is already installed"
    echo -n "Action: [U]pdate, [R]emove, [S]kip? "
    read -r reply
    case "$reply" in
      [Uu]) yay -S "$pkgname" ;;
      [Rr]) yay -Rns "$pkgname" ;;
      *) echo "⏭️  Skipped $pkgname" ;;
    esac
  done
}

_pkg_completion() {
  local matches
  matches=($(yay -Slq | fzf -m --query="${words[CURRENT]}" --height 40% --layout=reverse))
  if [[ -n "$matches" ]]; then
    compadd -a matches
  fi
}
compdef _pkg_completion pkg

alias cleaner='~/stash/scripts/cleaner.sh'
alias power-mode='sudo ~/stash/scripts/ultimate-mode.sh'
alias ls='eza --icons --group-directories-first'
alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'
alias nv='nvim'
alias cat='bat'

fastfetch
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

export PATH=$PATH:/home/loyst/.spicetify
export FZF_DEFAULT_OPTS=" \
--color=bg+:#252a2d,bg:#1c2023,spinner:#a8c292,hl:#a699c4 \
--color=fg:#c0c8cf,header:#7a858e,info:#8bafc4,pointer:#8bafc4 \
--color=marker:#a8c292,fg+:#dde2e6,prompt:#a699c4,hl+:#c294b2"
