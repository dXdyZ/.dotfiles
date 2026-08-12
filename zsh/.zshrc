# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"


export EDITOR=nvim
export VISUAL=nvim
export LANG=ru_RU.UTF-8

# Настройка zsh-autosuggestions (дополнение как в Fish)
# Цвет подсказки (можно поменять на 'fg=8', 'fg=240' или другой темно-серый)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
# Стратегия предложения: искать в истории (default) и дополнять текущую команду
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# Принять предложение по Ctrl+Space или стрелке вправо
bindkey '^ ' autosuggest-accept
bindkey '^[[C' autosuggest-accept  # Часто это стрелка вправо


# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME="robbyrussell"
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(  
  git
  z
  zsh-autosuggestions
  docker
  zsh-syntax-highlighting
  docker-compose
  copyfile
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

#alias ls="lsd -1 --color=auto"  # Это переопределит алиас от Oh My Zsh
alias clear='printf "\033[3J\033[H\033[2J"'
alias vim='nvim'


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


export LS_COLORS="$(echo $LS_COLORS | sed 's/42/00/g' | sed 's/44/00/g' | sed 's/30;00/01;32/g')"



# ============================================
# Настройка цветов для zsh-syntax-highlighting
# ============================================

# Цвета Tokyo Night
# Голубой: #7aa2f7
# Фиолетовый: #bb9af7
# Розовый: #f7768e
# Зеленый: #9ece6a
# Желтый: #e0af68
# Оранжевый: #ff9e64
# Серый: #565f89
# Белый: #c0caf5

# Команды (правильные) - голубой
ZSH_HIGHLIGHT_STYLES[command]=fg=#7aa2f7
# Команды (неправильные) - розовый
ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=#f7768e
# Пути (существующие) - зеленый
ZSH_HIGHLIGHT_STYLES[path]=fg=#9ece6a
# Пути (несуществующие) - красный
ZSH_HIGHLIGHT_STYLES[path_failure]=fg=#f7768e
# Кавычки - желтый
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=#e0af68
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=#e0af68
# Опции - фиолетовый
ZSH_HIGHLIGHT_STYLES[option]=fg=#bb9af7
# Аргументы - белый
ZSH_HIGHLIGHT_STYLES[commandparameter]=fg=#c0caf5
# Красные - оранжевый
ZSH_HIGHLIGHT_STYLES[redirection]=fg=#ff9e64
# Зарезервированные слова (if, for, etc) - фиолетовый
ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=#bb9af7
# Псевдонимы - голубой
ZSH_HIGHLIGHT_STYLES[alias]=fg=#7aa2f7
# Функции - зеленый
ZSH_HIGHLIGHT_STYLES[function]=fg=#9ece6a


# Переопределяем цвет стрелки в robbyrussell
PROMPT="%(?:%{$fg_bold[blue]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT+=' %{$fg[cyan]%}%~%{$reset_color%} $(git_prompt_info)'
