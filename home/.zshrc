unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     operatingSystem=Linux;;
    Darwin*)    operatingSystem=Mac;;
    CYGWIN*)    operatingSystem=Cygwin;;
    MINGW*)     operatingSystem=MinGw;;
    *)          operatingSystem="UNKNOWN:${unameOut}"
esac
unset unameOut

if [[ $operatingSystem == "Linux" ]]; then
    n=$(nice)
    # increse process priotiy if user is root, this is useful if you're loggin in while the system is under high load
    if [[ $EUID -eq 0 ]]; then
        renice -n -20 $$ >/dev/null
        ionice -c 2 -n 0 -p $$ >/dev/null
    fi
fi

stty -ixon -ixoff 2>/dev/null
unicode_start 2>/dev/null
kbd_mode -u 2>/dev/null # set unicode mode
kbd_mode 2>/dev/null # check keyboard mode, should be Unicode (UTF-8)

# save emacs!
if [[ "$TERM" == "dumb" ]]
then
    unsetopt zle
    unsetopt prompt_cr
    unsetopt prompt_subst
    unfunction precmd
    unfunction preexec
    PS1='$ '
    return
fi

bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line

# TODO: do the following for htop, too.
unalias tmux 2>/dev/null
if [ -f $(which tmux 2>/dev/null) ]; then
    if [ ! -f "$HOME/.tmux.conf_configured" ]; then
        if [[ $(tmux -V) == *"1."* ]]; then
            unlink "$HOME/.tmux.conf" 2>/dev/null
            ln -s "$HOME/.homesick/repos/dotfiles/home/.tmux.conf_v1" "$HOME/.tmux.conf"
        fi
        if [[ $(tmux -V) == *"2."* ]]; then
            unlink "$HOME/.tmux.conf" 2>/dev/null
            ln -s "$HOME/.homesick/repos/dotfiles/home/.tmux.conf_v2" "$HOME/.tmux.conf"
        fi
        touch "$HOME/.tmux.conf_configured"
    fi
fi

unalias sudo 2>/dev/null
unalias make 2>/dev/null
unalias cmake 2>/dev/null
unalias gcc 2>/dev/null
unalias g++ 2>/dev/null
unalias c++ 2>/dev/null
condition_for_tmux_mem_cpu_load=1
if [[ \
    $EUID -eq 0 && \
    -f $(which sudo 2>/dev/null) && \
    -f $(which make 2>/dev/null) && \
    -f $(which cmake 2>/dev/null) && \
    -f $(which gcc 2>/dev/null) && \
    -f $(which g++ 2>/dev/null) && \
    -f $(which c++ 2>/dev/null) \
    ]]; then

    condition_for_tmux_mem_cpu_load=0
fi

distro=''
if [[ $operatingSystem == "Linux" ]]; then
    is_done=false
    distro_result=$(lsb_release -i)

    if [ $? -eq 0 ]; then
        if [[ $distro_result =~ "Ubuntu" ]]; then
            distro="Ubuntu"
        fi
        if [[ $distro_result =~ "Fedora" ]]; then
            distro="Fedora"
        fi
        if [[ $distro_result =~ "Debian" ]]; then
            distro="Debian"
        fi
        if [[ $distro_result =~ "Gentoo" ]]; then
            distro="Gentoo"
        fi
        is_done=true
    fi

    unset is_done
    unset distro_result
fi

# aliases
if [[ $operatingSystem == "Mac" ]]; then
    alias ls='ls -h -G'
    alias make="make -j\$(sysctl -n hw.ncpu)"
else
    alias ls='ls -h --color'
    alias make="make -j\$(nproc)"
    alias iotop='iotop -d 1 -P -o'
fi

alias sudo='sudo SSH_AUTH_SOCK=$SSH_AUTH_SOCK'
alias sudosu='sudo su -'
alias pls='sudo'
alias tmux='tmux -2 -u'
alias tmuxa='tmux list-sessions 2>/dev/null 1>&2 && tmux a || tmux'
alias tmux-detach='tmux detach'
alias ll='ls -l'
alias la='ls -al'
alias grep='grep --color'
alias htop='htop -d 10'
alias rsync="rsync -v --progress --numeric-ids --human-readable --stats --copy-links --hard-links"
alias ask_yn='select yn in "Yes" "No"; do case $yn in Yes) ask_yn_y_callback; break;; No) ask_yn_n_callback; break;; esac; done'
alias brexit='echo "disable all network interfaces, delete 50% of all files and then reboot the dam thing!"; ask_yn_y_callback() { echo "See ya and peace out!"; exit; }; ask_yn_n_callback() { echo -n ""; }; ask_yn'
alias urlencode='python3 -c "import sys, urllib.parse; print(urllib.parse.quote_plus(sys.stdin.read()));"'
alias urldecode='python3 -c "import sys, urllib.parse; print(urllib.parse.unquote_plus(sys.stdin.read()));"'
alias ceph-osd-heap-release='ceph tell "osd.*" heap release' # release unused memory by the ceph osd daemon(s).
alias clean-swap='sudo swapoff -a; sudo swapon -a'
alias reset-swap='clean-swap'
alias drop-fscache='sync; sudo echo 3 > /proc/sys/vm/drop_caches'
alias reset-fscache='drop-fscache'
alias dns-retransfer-zones='rndc retransfer'
alias dns-reload-zones='rndc reload'
alias get-ip-local='ip a'
alias get-ip-internet='curl https://ip.compilenix.org'
alias get-network-listening='sudo netstat -tunpl'
alias get-network-active-connections='sudo netstat -tun'
alias get-network-active-connections-by-type="sudo netstat -tun | awk '{print \$6}' | sort | uniq -c | sort -n | tail -n +2"
alias get-network-active-connections-by-type-program="sudo netstat -tunp | awk '{print \$6,\$7}' | sort | uniq -c | sort -n | tail -n +2"
alias get-iptables-v4='sudo iptables -L -v'
alias get-iptables-v4-nat='sudo iptables -t nat -L -v'
alias get-iptables-v6='sudo ip6tables -L -v'
alias get-iptables-v6-nat='sudo ip6tables -t nat -L -v'
alias get-mem-dirty='cat /proc/meminfo | grep Dirty'
alias watch-mem-dirty='watch -n 1 "cat /proc/meminfo | grep Dirty"'
alias watch-ceph-status='watch -n 1 ceph -s'
alias get-date='date +%s'
alias get-date-from-unixtime='read a; date -d @$a'
alias get-date-hex='get-date | xargs printf "%x\n"'
alias get-date-from-hex-unixtime='read a; echo $a | echo $((16#$_))'
alias get-date-from-hex='get-date-from-hex-unixtime | date -d @$_'
alias get-hpkp-pin='openssl x509 -pubkey -noout | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -binary | openssl enc -base64'
function get-cert-raw {
    hostName=$1
    portNumber=$2
    echo | openssl s_client -connect ${hostName}:${portNumber} -servername ${hostName} 2>/dev/null | openssl x509
}
function get-cert {
    hostName=$1
    portNumber=$2
    get-cert-raw $hostName $portNumber | openssl x509 -noout -text
}
export dnsStats='+stats'
function set-dns-stats-enable {
    export dnsStats='+stats'
}
function set-dns-stats-disable {
    export dnsStats=''
}
export dnsTrace=''
function set-dns-trace-enable {
    export dnsTrace='+trace'
}
function set-dns-trace-disable {
    export dnsTrace=''
}
alias get-dns="dig +noall \$(echo \$dnsStats) \$(echo \$dnsTrace) +answer"
alias get-dns-dnssec="dig +noall \$(echo \$dnsStats) \$(echo \$dnsTrace) +answer +dnssec"
alias get-dns-dnssec-verify="dig +noall \$(echo \$dnsStats) \$(echo \$dnsTrace) +answer +dnssec +sigchase"
alias get-picture-metadata-curl='read a; curl -sr 0-1024 $a | strings'
alias get-picture-metadata-file='read a; dd bs=1 count=1024 if=$a 2>/dev/null | strings'
alias get-weather='curl wttr.in'
alias get-weather-in='echo -n "enter location (name or 3-letters airport code): "; read a; curl wttr.in/$a'
alias get-moon-phase='curl wttr.in/Moon'
alias get-random-alias='alias | sort --random-sort | head -n 1'
alias get-random-password='base64 </dev/urandom | tr -dc a-zA-Z0-9 | head -c'
alias get-mysql-selects='ngrep -d eth0 -i "select" port 3306'
alias get-mysql-updates='ngrep -d eth0 -i "update" port 3306'
alias get-mysql-inserts='ngrep -d eth0 -i "insert" port 3306'
alias get-fortune='echo -e "\n$(tput bold)$(tput setaf $(shuf -i 1-5 -n 1))$(fortune)\n$(tput sgr0)"'
alias get-process-zombie="ps aux | awk '{if (\$8==\"Z\") { print \$2 }}'"
alias get-ssh-pubkey="more ~/.ssh/id_ed25519.pub | xclip -selection clipboard | echo '=> Public key copied to pasteboard.'"
alias get-ssh-prikey="more ~/.ssh/id_ed25519 | xclip -selection clipboard | echo '=> Private key copied to pasteboard.'"
function get-debian-package-description { read input; dpkg -l ${input} | grep --color " ${input} " | awk '{$1=$2=$3=$4="";print $0}' | sed 's/^ *//' }
function get-debian-package-updates { apt --just-print upgrade 2>&1 | perl -ne 'if (/Inst\s([\w,\-,\d,\.,~,:,\+]+)\s\[([\w,\-,\d,\.,~,:,\+]+)\]\s\(([\w,\-,\d,\.,~,:,\+]+)\)? /i) {print "$1 (\e[1;34m$2\e[0m -> \e[1;32m$3\e[0m)\n"}'; }
# Create a data URL from a file
function get-dataurl {
    local mimeType
    mimeType=$(file -b --mime-type "$1")
    if [[ $mimeType == text/* ]]; then
        mimeType="${mimeType};charset=utf-8"
    fi
    echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}
function git-repo-browser {
    # Figure out github repo base URL
    local base_url
    base_url=$(git config --get remote.origin.url)
    base_url=${base_url%\.git} # remove .git from end of string

    # Fix git@github.com: URLs
    base_url=${base_url//git@github\.com:/https:\/\/github\.com\/}

    # Fix git://github.com URLS
    base_url=${base_url//git:\/\/github\.com/https:\/\/github\.com\/}

    # Fix git@bitbucket.org: URLs
    base_url=${base_url//git@bitbucket.org:/https:\/\/bitbucket\.org\/}

    # Fix git@gitlab.com: URLs
    base_url=${base_url//git@gitlab\.com:/https:\/\/gitlab\.com\/}

    # Fix git@compilenix.com: URLs
    base_url=${base_url//git@git\.compilenix\.org:/https:\/\/git\.compilenix\.org\/}

    # Validate that this folder is a git folder
    if ! git branch 2>/dev/null 1>&2 ; then
        echo "Not a git repo!"
        exit $?
    fi

    # Find current directory relative to .git parent
    full_path=$(pwd)
    git_base_path=$(cd "./$(git rev-parse --show-cdup)" || exit 1; pwd)
    relative_path=${full_path#$git_base_path} # remove leading git_base_path from working directory

    # If filename argument is present, append it
    if [ "$1" ]; then
        relative_path="$relative_path/$1"
    fi

    # Figure out current git branch
    # git_where=$(command git symbolic-ref -q HEAD || command git name-rev --name-only --no-undefined --always HEAD) 2>/dev/null
    git_where=$(command git name-rev --name-only --no-undefined --always HEAD) 2>/dev/null

    # Remove cruft from branchname
    branch=${git_where#refs\/heads\/}

    [[ $base_url == *bitbucket* ]] && tree="src" || tree="tree"
    url="$base_url/$tree/$branch$relative_path"


    echo "Calling $(type xdg-open) for $url"

    xdg-open "$url" &> /dev/null || (echo "Using $(type xdg-open) to xdg-open URL failed." && exit 1);
}
alias set-zsh-highlighting-full='ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern line)'
alias set-zsh-highlighting-default='ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)'
alias set-zsh-highlighting-off='ZSH_HIGHLIGHT_HIGHLIGHTERS=()'
alias set-terminal-powersave-off='setterm -blank 0 -powersave off'
alias set-terminal-powersave-on='setterm -blank 60 -powersave on'
alias set-megaraid-alarm-enabled='sudo megacli -AdpSetProp AlarmEnbl'
alias set-megaraid-alarm-disabled='sudo megacli -AdpSetProp AlarmDsbl'
alias set-megaraid-alarm-silent='sudo megacli -AdpSetProp AlarmSilence'
alias set-keyboard-mode-raw='sudo kbd_mode -s'
alias set-display-off='sleep 1; xset dpms force standby'
alias set-display-on='xset dpms force on'
function add-iptables-allow-out-http_s { sudo iptables -A OUTPUT -p TCP --match multiport --dports 80,443 -d "$1" -j ACCEPT -m comment --comment "Temporary: $1"; }
function remove-iptables-allow-out-http_s { sudo iptables -D OUTPUT -p TCP --match multiport --dports 80,443 -d "$1" -j ACCEPT -m comment --comment "Temporary: $1"; }
alias update-gentoo='echo "do a \"emerge --sync\"?"; ask_yn_y_callback() { sudo emerge --sync; }; ask_yn_n_callback() { echo ""; }; ask_yn; sudo emerge -avDuN world'
alias update-archlinux-pacman='sudo pacman -Syu'
alias update-archlinux-yaourt='sudo yaourt -Syu'
alias update-archlinux-yaourt-aur='sudo yaourt -Syu --aur'
alias update-debian='echo "do a \"apt update\"?"; ask_yn_y_callback() { sudo apt update; }; ask_yn_n_callback() { echo ""; }; ask_yn; echo; get-debian-package-updates | while read -r line; do echo -en "$line $(echo $line | awk "{print \$1}" | get-debian-package-description)\n"; done; echo; sudo apt upgrade; sudo apt autoremove; sudo apt autoclean'
alias update-yum='sudo yum update'
alias update-redhat='sudo dnf update'
alias update-fedora='update-redhat'
function git-reset { for i in $*; do echo -e "\033[0;36m$i\033[0;0m"; pushd "$i"; git reset --hard; popd >/dev/null; done; }
function fix-antigen_and_homesick_vim {
    sudo rm /usr/local/bin/tmux-mem-cpu-load
    # Migrate from 1.x antigen to 2.x antigen
    if [[ -d ~/.homesick/repos/dotfiles/home/.antigen ]]
    then
        pushd ~/.homesick/repos
        rm -rf dotfiles
        git clone --recursive https://github.com/compilenix/dotfiles.git
        popd >/dev/null
        pushd ~
        rm -rf .antigen
        rm -rf .vim/bundle/vundle
        ln -sfv .homesick/repos/dotfiles/antigen .antigen
        popd >/dev/null
        pushd ~/.vim/bundle
        ln -sfv ../../.homesick/repos/dotfiles/vim/vundle vundle
        popd >/dev/null
    fi
    antigen-cleanup
    git-reset ~/.homesick/repos/*
    git-reset ~/.vim/bundle/*
    homeshick pull
    homeshick link
    antigen update
    for i in ~/.vim/bundle/*
    do
        pushd "$i"
        git pull
        popd >/dev/null
    done
    vim +PluginInstall +qa
    rm ~/.tmux.conf_configured

    exec zsh
}
alias update-zshrc='pushd ~/.homesick/repos/dotfiles; git status; popd >/dev/null; echo "This will reset all changes you may made to files which are symlinks at your home directory, to check this your own: \"# cd ~/.homesick/repos/dotfiles && git status\"\nDo you want preced anyway?"; function ask_yn_y_callback { fix-antigen_and_homesick_vim; }; function ask_yn_n_callback { echo -n ""; }; ask_yn'
alias update-code-insiders-rpm='wget "https://go.microsoft.com/fwlink/?LinkID=760866" -O /tmp/code-insiders.rpm && sudo yum install -y /tmp/code-insiders.rpm && rm /tmp/code-insiders.rpm'
alias test-mail-sendmail='echo "Subject: test" | sendmail -v '
alias test-mail-mutt='mutt -s "test" '
function apache-configtest { sudo apache2ctl -t }
function apache-reload { apache-configtest && { sudo systemctl reload apache2 || sudo systemctl status apache2 } }
function apache-restart { apache-configtest && { sudo systemctl restart apache2 || sudo systemctl status apache2 } }
function nginx-configtest { sudo nginx -t }
function nginx-reload { nginx-configtest && { sudo systemctl reload nginx || sudo systemctl status nginx } }
function nginx-restart { nginx-configtest && { sudo systemctl restart nginx || sudo systemctl status nginx } }
function read-logfile {
    file="$1"
    sudo cat "${file}" | ccze -A | less -R
}
alias root='sudo su -l root'
alias processes='ps -aux'
alias memory='free -h -m'
alias disk-space='df -h'
alias disks='lsblk'
alias systemctl-status='systemctl status'

if [[ $distro == "Ubuntu" ]]; then
    alias install='sudo apt install '
    alias find-package='apt search '
    alias update='update-debian'
    alias upgrade='update-debian && do-release-upgrade'
fi
if [[ $distro == "Debian" ]]; then
    alias install='sudo apt install '
    alias find-package='apt search '
    alias update='update-debian'
    alias upgrade='update-debian && do-release-upgrade'
fi
if [[ $distro == "Fedora" ]]; then
    alias install='sudo dnf install '
    alias find-package='dnf search '
    alias update='update-fedora'
    alias upgrade='update-fedora'
fi
if [[ $distro == "Gentoo" ]]; then
    alias install='sudo emerge -av '
    alias find-package='eix '
    alias update='update-gentoo'
    alias upgrade='update-gentoo'
fi

export PATH="$HOME/bin:$HOME/bin_dotfiles:$HOME/sh:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/bin:/sbin:$PATH"
export EDITOR=vim
export LANG="en_US.UTF-8"
export HISTSIZE=10000
export HISTFILE="$HOME/.history"
export SAVEHIST=$HISTSIZE
# Don’t clear the screen after quitting a manual page.
#export MANPAGER='less -X';

# if it's an ssh session export GPG_TTY
if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
    GPG_TTY=$(tty)
    export GPG_TTY
fi

setopt HIST_IGNORE_ALL_DUPS   # Delete old recorded entry if new entry is a duplicate.
setopt EXTENDEDGLOB
setopt EXTENDED_HISTORY       # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY     # Write to the history file immediately, not when the shell exits.
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_SPACE      # Don't record an entry starting with a space.
setopt HIST_VERIFY            # Don't execute immediately upon history expansion.
unsetopt SHARE_HISTORY

if [ ! -f "$HOME/.tmux.conf_include" ]; then
    touch "$HOME/.tmux.conf_include"
fi

if [ ! -f "$HOME/.gitconfig_include" ]; then
    echo -e "# vim: sw=4 et\n\n[user]\n\tname = $(whoami)\n#\temail = Compilenix@gmail.org\n#\tsigningkey = 3C713073CAC92AE0\n#[commit]\n\t# https://help.github.com/articles/signing-commits-using-gpg/\n#\tgpgsign = true\n#[credential]\n#\thelper = store\n#[core]\n#\tfileMode = false\n" > "$HOME/.gitconfig_include"
fi

source "$HOME/.homesick/repos/homeshick/homeshick.sh"
fpath=($HOME/.homesick/repos/homeshick/completions $fpath)

ZSH_TMUX_AUTOSTART=false
ZSH_TMUX_AUTOQUIT=false
ZSH_TMUX_FIXTERM=false
COMPLETION_WAITING_DOTS="true"

source $HOME/.antigen/antigen.zsh
antigen use oh-my-zsh
antigen theme denysdovhan/spaceship-prompt

SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_SEPARATE_LINE=false
SPACESHIP_TIME_SHOW=true
SPACESHIP_USER_SHOW=true
SPACESHIP_HOST_SHOW=true
SPACESHIP_HOST_SHOW_FULL=false
SPACESHIP_BATTERY_THRESHOLD=30
SPACESHIP_EXIT_CODE_SHOW=true

SPACESHIP_NODE_SHOW=false
SPACESHIP_RUBY_SHOW=false
SPACESHIP_ELIXIR_SHOW=false
SPACESHIP_XCODE_SHOW_LOCAL=false
SPACESHIP_XCODE_SHOW_GLOBAL=false
SPACESHIP_SWIFT_SHOW_LOCAL=false
SPACESHIP_SWIFT_SHOW_GLOBAL=false
SPACESHIP_GOLANG_SHOW=false
SPACESHIP_PHP_SHOW=false
SPACESHIP_RUST_SHOW=false
SPACESHIP_HASKELL_SHOW=false
SPACESHIP_JULIA_SHOW=false
SPACESHIP_DOCKER_SHOW=false
SPACESHIP_PYENV_SHOW=false
SPACESHIP_DOTNET_SHOW=false
SPACESHIP_EMBER_SHOW=false
SPACESHIP_PACKAGE_SHOW=false

#antigen bundle systemd
antigen bundle colored-man-pages
antigen bundle command-not-found

if [[ ${condition_for_tmux_mem_cpu_load} -eq 0 ]]; then
    #antigen bundle thewtex/tmux-mem-cpu-load
    antigen bundle compilenix/tmux-mem-cpu-load
fi

# antigen bundle RobSis/zsh-completion-generator
antigen bundle zsh-users/zsh-completions
antigen bundle ascii-soup/zsh-url-highlighter

if which tmux &> /dev/null
    then
    # Configuration variables
    #
    # Automatically start tmux
    [[ -n "$ZSH_TMUX_AUTOSTART" ]] || ZSH_TMUX_AUTOSTART=false
    # Only autostart once. If set to false, tmux will attempt to
    # autostart every time your zsh configs are reloaded.
    [[ -n "$ZSH_TMUX_AUTOSTART_ONCE" ]] || ZSH_TMUX_AUTOSTART_ONCE=true
    # Automatically connect to a previous session if it exists
    [[ -n "$ZSH_TMUX_AUTOCONNECT" ]] || ZSH_TMUX_AUTOCONNECT=true
    # Automatically close the terminal when tmux exits
    [[ -n "$ZSH_TMUX_AUTOQUIT" ]] || ZSH_TMUX_AUTOQUIT=$ZSH_TMUX_AUTOSTART
    # Set term to screen or screen-256color based on current terminal support
    [[ -n "$ZSH_TMUX_FIXTERM" ]] || ZSH_TMUX_FIXTERM=true
    # Set '-CC' option for iTerm2 tmux integration
    [[ -n "$ZSH_TMUX_ITERM2" ]] || ZSH_TMUX_ITERM2=false
    # The TERM to use for non-256 color terminals.
    # Tmux states this should be screen, but you may need to change it on
    # systems without the proper terminfo
    [[ -n "$ZSH_TMUX_FIXTERM_WITHOUT_256COLOR" ]] || ZSH_TMUX_FIXTERM_WITHOUT_256COLOR="screen"
    # The TERM to use for 256 color terminals.
    # Tmux states this should be screen-256color, but you may need to change it on
    # systems without the proper terminfo
    [[ -n "$ZSH_TMUX_FIXTERM_WITH_256COLOR" ]] || ZSH_TMUX_FIXTERM_WITH_256COLOR="screen-256color"

    # Determine if the terminal supports 256 colors
    if [[ `tput colors` == "256" ]]
    then
        export ZSH_TMUX_TERM=$ZSH_TMUX_FIXTERM_WITH_256COLOR
    else
        export ZSH_TMUX_TERM=$ZSH_TMUX_FIXTERM_WITHOUT_256COLOR
    fi

    # Wrapper function for tmux.
    function _zsh_tmux_plugin_run()
    {
        # We have other arguments, just run them
        if [[ -n "$@" ]]
        then
            tmux $@
        # Try to connect to an existing session.
        elif [[ "$ZSH_TMUX_AUTOCONNECT" == "true" ]]
        then
            tmux `[[ "$ZSH_TMUX_ITERM2" == "true" ]] && echo '-CC '` attach || tmux `[[ "$ZSH_TMUX_ITERM2" == "true" ]] && echo '-CC '` `[[ "$ZSH_TMUX_FIXTERM" == "true" ]] && echo '-f '$_ZSH_TMUX_FIXED_CONFIG` new-session
            [[ "$ZSH_TMUX_AUTOQUIT" == "true" ]] && exit
        # Just run tmux, fixing the TERM variable if requested.
        else
            tmux `[[ "$ZSH_TMUX_ITERM2" == "true" ]] && echo '-CC '` `[[ "$ZSH_TMUX_FIXTERM" == "true" ]] && echo '-f '$_ZSH_TMUX_FIXED_CONFIG`
            [[ "$ZSH_TMUX_AUTOQUIT" == "true" ]] && exit
        fi
    }

    # Use the completions for tmux for our function
    # compdef _tmux zsh_tmux_plugin_run

    # Autostart if not already in tmux and enabled.
    if [[ ! -n "$TMUX" && "$ZSH_TMUX_AUTOSTART" == "true" ]]
    then
        _zsh_tmux_plugin_run
    fi
fi

[ -r /etc/ssh/ssh_known_hosts ] && _global_ssh_hosts=(${${${${(f)"$(</etc/ssh/ssh_known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _global_ssh_hosts=()
[ -r ~/.ssh/known_hosts ] && _ssh_hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
[ -r ~/.ssh/config ] && _ssh_config=($(cat ~/.ssh/config | sed -ne 's/Host[=\t ]//p')) || _ssh_config=()
[ -r /etc/hosts ] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()
hosts=(
  "$_ssh_config[@]"
  "$_global_ssh_hosts[@]"
#  "$_ssh_hosts[@]"
#   "$_etc_hosts[@]"
#  "$HOST"
#  localhost
)
zstyle ':completion:*:hosts' hosts $hosts

export nvmAutoEnable=0
export nvmEnabled=0
function enable-nvm {
    [[ nvmEnabled -eq 1 ]] && return 0
    echo "loading Node Version Manager..."
    export NVM_DIR="$(realpath $HOME/.nvm)"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || {
        echo "you need nvm (https://github.com/creationix/nvm)"
        unset NVM_DIR
        return 1
    }
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
    export nvmEnabled=1
}

function disable-nvm {
    unset NVM_DIR
    export nvmEnabled=0
}

function use-nvm {
    enable-nvm || return 1
    nvm i || return 1
}

if [[ -f .nvmrc ]]
then
    if [[ $nvmAutoEnable == 1 ]]
    then
        [[ $nvmEnabled && "$(nvm version 2>/dev/null)" == "$(cat .nvmrc)" ]] || use-nvm
    fi
fi

function my-chpwd {
    if [[ -f .nvmrc ]]
    then
        [[ $nvmAutoEnable != 1 ]] && return
        [[ "$(nvm version 2>/dev/null)" == "$(cat .nvmrc)" ]] || use-nvm
    fi
}
chpwd_functions=(${chpwd_functions[@]} "my-chpwd")

antigen bundle zsh-users/zsh-syntax-highlighting
set-zsh-highlighting-full
export ZSH_HIGHLIGHT_MAXLENGTH=80

# if [ ! -z "$TMUX" ]; then
    antigen bundle zsh-users/zsh-autosuggestions
# fi

if [ -f "$HOME/.zshrc_include" ]; then
    source "$HOME/.zshrc_include"
else
    echo -e "#export SSH_AUTH_SOCK=\$XDG_RUNTIME_DIR/keeagent.sock\n#export EDITOR=nano" >"$HOME/.zshrc_include"
fi

antigen apply
autoload -U compinit && compinit -u
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=cyan" # http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Character-Highlighting

if [ ! -f "$HOME/.gnupg/gpg-agent.env" ]; then
    mkdir -pv "$HOME/.gnupg"
    chmod 0700 "$HOME/.gnupg"
    touch "$HOME/.gnupg/gpg-agent.env"
fi

if [[ $operatingSystem == "Linux" ]]; then
    if [[ $EUID -eq 0 ]]; then
        renice -n $n $$ > /dev/null
    fi
fi

echo "here is a random shell alias you might not known about: $(get-random-alias)"

unset n
unset condition_for_tmux_mem_cpu_load

# vim: sw=4 et
