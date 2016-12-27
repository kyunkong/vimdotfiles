#!/usr/bin/env bash
#------------------------------------------------------------------------
# File Name:     vim.wrapper.sh
# Author:        Fung Kong
# Mail:          kyun.kong@gmail.com
# Created Time:  2016-12-20 20:46:57
# Description:   This script is for synchronizing my VIM configuration with
#                my github repository, including installing to a new machine,
#                pulling/updating from the github, pushing the local
#                modifications to the github
# Platform:      Linux
#------------------------------------------------------------------------
timeStamp=$(date +%Y%m%d)
logfile=~/vim.wrapper.$timeStamp.log
branch=master
gitdir=~/.vim

# define the usage hint
usage(){
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo -e "+++Synchronize the vim configuration file with the github+++++++++++"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo -e "\n\toption 'Install' for newly installation;\n
    \toption 'Pull' for pulling the github to the local repo;\n
    \toption 'Push' for pushing the local repo to the github\n"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    # exit 1
}

# check the local git repository exists
dirstatus(){
    if [[ ! -d $gitdir ]]; then
        echo -e "+++Local git repository doesn't exist...\n" |tee -a $logfile
        dirstat=0
    else
        dirstat=1
    fi
    return $dirstat
}

# check the git status
gitstatus(){
    if [[ -n "$(git status --porcelain)" ]]; then
        echo -e "+++Your local repo is not clean." |tee -a $logfile
        gitstat=0
    else
        gitstat=1
    fi
    return $gitstat
}

rcstatus(){
    rc=$?
    if [[ $rc -ne 0 ]]; then
        echo -e '+++Something wrong with the git command, please have a check.'
        exit 1
    fi
}
# define the main function for the newly installation
INSTALL(){
    # backup is always essential
    dirstatus
    if [[ $dirstat == 1 ]]; then
        echo -e "+++Backing up the $gitdir dir...\nmv ${gitdir} ${gitdir}_old_$timeStamp" |tee -a $logfile
        mv $gitdir ${gitdir}_old_$timeStamp |tee -a $logfile
        echo -e "+++Backing up $gitdir folder done...\n" |tee -a $logfile
    fi
    for file in ~/.bashrc ~/.vimrc ~/.inputrc ~/.screenrc
    do
        echo -e "+++Backing up $file...\nmv $file ${file}.${timeStamp}.bak"|tee -a $logfile
        mv $file ${file}.${timeStamp}.bak >/dev/null 2>&1
        echo -e "+++Backup the $file end...\n"|tee -a $logfile
    done


    echo -e 'Cloning vimdotfiles the github repository:
    git clone https://github.com/kyunkong/vimdotfiles.git $gitdir\n' |tee -a $logfile
    git clone https://github.com/kyunkong/vimdotfiles.git $gitdir|tee -a $logfile
    rcstatus

    # clone the repository from github
    echo -e 'We need to install the vundle first:'
    git clone https://github.com/VundleVim/Vundle.vim.git $gitdir/bundle/Vundle.vim
    rcstatus

    echo -e 'configuring the solarized theme...\n'
    git clone git://github.com/altercation/vim-colors-solarized.git  && cp vim-colors-solarized/colors/solarized.vim $gitdir/bundle/vim-colors-solarized
    rcstatus


    echo -e '
    \n#Creating the symbolic links for the rc files\n
    ln -s $gitdir/vimrc ~/.vimrc
    ln -s $gitdir/bashrc ~/.bashrc
    ln -s $gitdir/inputrc ~/.inputrc
    ln -s $gitdir/screenrc ~/.screenrc
    ' |tee -a $logfile
    ln -s $gitdir/vimrc ~/.vimrc|tee -a $logfile
    ln -s $gitdir/bashrc ~/.bashrc|tee -a $logfile
    ln -s $gitdir/inputrc ~/.inputrc|tee -a $logfile
    ln -s $gitdir/screenrc ~/.screenrc|tee -a $logfile
    echo -e "Install the vundle plugin...\n"
    vim +PluginInstall +qall

    # Solarized color theme setting
    echo -e '+++Setting up the gnome-terminal:\n
    git clone https://github.com/Anthony25/gnome-terminal-colors-solarized.git $gitdir/gnome-terminal-colors-solarized\n
    '|tee -a $logfile
    git clone https://github.com/Anthony25/gnome-terminal-colors-solarized.git $gitdir/gnome-terminal-colors-solarized
    rcstatus

    echo -e "+++Please run the following commands for gnome-terminal Solarized theme\n"|tee -a $logfile
    echo -e '\e[1;31m
    sh $gitdir/gnome-terminal-colors-solarized/set_dark.sh
    eval `dircolors $HOME/.dir_colors/dircolors`
    \e[0m
    ' |tee -a $logfile
    echo -e '+++Removing the old gnome submodule...\n
    +++rm -rf $gitdir/gnome-terminal-colors-solarized'|tee -a $logfile

    echo -e "+++Installation done...\n" |tee -a $logfile
}


UPDATE(){
    dirstatus
    if [[ $dirstat == 0 ]]; then
        exit 1
    else
        cd $gitdir
        gitstatus
        if [[ $gitstat == 0 ]]; then
            echo -e "+++Would you like to be overwritten by the remote repo?(Y/y or N/n)"|tee -a $logfile
            typeset -u choice
            echo ">"
            read choice
            # echo $choice
            case $choice in
                Y) git reset --hard
                    git pull origin $branch
                    ;;
                N) echo -e "+++Please resolve the conflicts manual and run the script again...\n"|tee -a $logfile
                    exit 1
                    ;;
                *) echo -e "+++Invalid option, please enter Y/y or N/n...\n"|tee -a $logfile
                    # exit 1
                    UPDATE
                    ;;
            esac
        else
            echo -e "+++The local repo is clean, pull repo from remote to local is in action...\n"|tee -a $logfile
            git pull origin $branch
        fi
    fi
}


PUSH(){
    dirstatus
    if [[ $dirstat == 0 ]]; then
        exit 1
    else
        cd $gitdir
        echo -e "+++Please enter a commit message here...\n"|tee -a $logfile
        read msg
        if [[ -z $msg ]]; then
            msg="make some modifications"
        fi
        git add . --all
        git commit -m "$msg"
        git push -u origin $branch
    fi
}


# clear the screen
clear

#Display the menu title header
echo -e "\n\t\tVIM configuration toolkit\n"
usage

# Defile the menu prompt
PS3="Select an option and press Enter:"

# The select command defines what the menu will look like
select opt in Install Pull Push Quit
do
    case $opt in
        Install) INSTALL
            break
            ;;
        Pull) UPDATE
            break
            ;;
        Push) PUSH
            break
            ;;
        Quit) break
            ;;
        *) echo "Invalid options"
            ;;
    esac
done

