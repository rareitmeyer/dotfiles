# .bashrc file
# Copright 2017 Richard A. Reitmeyer

# get rid of unwanted aliases.
unalias -a

# Prompt
PS1="\w:\!\$ "

limit_shell() { mem="$1"; unit="$2"; quiet="$3"; case "$unit" in (kB) mem=`expr $mem \* 1024`;; (MB|MiB) mem=`expr $mem \* 1024 \* 1024`;; (GB|GiB) mem=`expr $mem \* 1024 \* 1024 \* 1024`;; esac; if [ "$quiet" != '-q' ]; then echo "setting limit to $mem"; fi; ulimit -S -d "$mem" -m "$mem"  -v "$mem"; unset mem; unset unit; }

# set default ulimit to something small
limit_shell 4 GiB -q

# don't save history to a file!  it's so irritating!
SAVEHIST=100
export SAVEHIST
HISTFILE=""
export HISTFILE

PYTHONPATH=/home/richard/python_mods
export PYTHONPATH


PATH=$HOME/local/bin:$HOME/local/go/bin:/usr/local/bin:/usr/local/pgsql/bin:$PATH
LD_LIBRARY_PATH=$HOME/local/lib:$HOME/local/grass-7.0.3/lib:/usr/local/lib:/usr/local/pgsql/lib:$LD_LIBRARY_PATH
export PATH LD_LIBRARY_PATH

CFLAGS="-I$HOME/local/include -I/usr/local/pgsql/include"
LDFLAGS="-L$HOME/local/lib -L/usr/local/pgsql/lib"
export CFLAGS LDFLAGS

GOROOT=$HOME/local/go
GOPATH=$HOME/gowork
export GOROOT GOPATH

PGDATA=/home/postgres/data
export PGDATA

PKG_CONFIG_PATH=$HOME/lib/pkgconfig
export PKG_CONFIG_PATH

EDITOR=vi
export EDITOR

PAGER=less
export PAGER

WNHOME=/home/richard/WordNet-3.0/dict
export WNHOME

# essential aliases
alias rebashrc="source ~/.bashrc"
alias vbashrc="vi ~/.bashrc"
alias pd=pushd
alias bd=popd
alias bc='bc -lq'
de() { docker exec -it "$1" /bin/bash; }
alias lynx="lynx --nocolor"

alias xclock='xclock -update 1 -digital -strftime "%Y-%m-%dT%H:%M:%S"'

alias pw='/usr/bin/python3 ~/src/misc/pw && clear'

# GNU indent settings
#     -bad    put a blank line after each declaration block
#     -bap    put a blank line after each proceedure
#     -bfda   line break after each function argument
#     -br     brace after if
#     -brs    brace right after struct
#     -bs     space between sizeof and (
#     -ce     "cuddle else" -- do } else { on one line.
#     -cs     put a space after every cast operator.
#     -hnl    honor newlines in the input file
#     -i4     standard indent is 4 spaces
#     -ip0    if there are extra unbalanced parens on line, ignore them
#     -l78    break lines longer than 78 characters
#     -nfc1   Don't dork with comments starting in column #1
#     -nlp    don't try to line up parens---it makes long exprs indent too far
#     -npcs   don't put a space between preoceedure call and paren
#     -psl    put return type on its own line.
gnu_indent_settings="-bad -bap -bfda -br -brs -bs -ce -cs -hnl -i4 -ip0 -l78 -nfc1 -nlp -npcs -psl"


# better ps
procinfo()
{
    procinfo_ps_options="-A -o user,pid,ppid,pcpu,osz,vsz,rss,pmem,nice,etime,time,args"
    if [ -n "$1" ]; then
        ps $procinfo_ps_options | egrep 'USER|'$1
    else
        ps $procinfo_ps_options
    fi
}


# su function: I want something that opens a new window for
# root with a big red background to emphasize that it's a `root' window.
# Unless I'm running `su' to become someone else, in which case I
# want a different look.
su()
{
    # Actual command-stuff
    if [ -z "$DISPLAY" ]; then
        # Run the command
        /bin/su "$@"
    else
        # Run the command in the background
        gnome-terminal --window-with-profile=su --execute /bin/su "$@" &
    fi
}


# Make sure enscript uses right page size.
enscript()
{
    enscript_prog=/bin/enscript
    if [ ! -x $enscript_prog ]; then
        enscript_prog=/usr/bin/enscript
        if [ ! -x $enscript_prog ]; then
            enscript_prog=/usr/local/bin/enscript
            if [ ! -x $enscript_prog ]; then
                echo "error: no enscript program found" 1>&2
                return
            fi
        fi
    fi
     $enscript_prog --media=Letter "$@"
}



# Kaggle container aliases:
kpython(){
  docker run -v $PWD:/tmp/working -w=/tmp/working --rm -it kaggle/python python "$@"
}
ikpython() {
  docker run -v $PWD:/tmp/working -w=/tmp/working --rm -it kaggle/python ipython
}
kjupyter() {
  #(sleep 3 && open "http://$(docker-machine ip docker2):8888")&
    docker run -v `dirname $PWD`:/tmp/working -w=/tmp/working/`basename $PWD` -p 127.0.0.1:8888:8888 --rm -it kaggle/python jupyter notebook --no-browser --no-mathjax --notebook-dir='.' --ip=0.0.0.0 "$@"
}





if [ -r $HOME/.startup ]; then
    if [ -z "$done_startup" ]; then
        source $HOME/.startup
    fi
fi

# alias for some things that want system python2.7 instead of mine.
alias qgis='PATH=/usr/local/bin:/usr/local/pgsql/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin LD_LIBRARY_PATH=/usr/local/lib:/usr/local/pgsql/lib qgis'

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
