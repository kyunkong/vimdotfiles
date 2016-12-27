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
branch=master
gitdir=~/.vim
dotfiledir=$gitdir/dotfiles

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
        echo -e "+++Local git repository doesn't exist...\n" 
        dirstat=0
    else
        dirstat=1
    fi
    return $dirstat
}

# check the git status
gitstatus(){
    if [[ -n "$(git status --porcelain)" ]]; then
        echo -e "+++Your local repo is not clean." 
        gitstat=0
    else
        gitstat=1
    fi
    return $gitstat
}

rcstatus(){
    rc=$?
    if [ $rc -ne 0 ]; then
        echo -e "Something wrong with the previous command, please have a check...\n"
        exit -1
    fi
}

# define the main function for the newly installation
INSTALL(){
    # backup is always essential
    dirstatus
    if [[ $dirstat == 1 ]]; then
        echo -e "+++Backing up the $gitdir dir...\nmv ${gitdir} ${gitdir}_old_$timeStamp"
        mv $gitdir ${gitdir}_old_$timeStamp
        echo -e "+++Backing up $gitdir folder done...\n"
    fi
    for file in ~/.bashrc ~/.vimrc ~/.inputrc ~/.screenrc
    do
        echo -e "+++Backing up $file...\nmv $file ${file}.${timeStamp}.bak"
        mv $file ${file}.${timeStamp}.bak >/dev/null 2>&1
        echo -e "+++Backup the $file end...\n"
    done

    #clone my vimrc repo
    echo -e 'Cloning vimdotfiles the github repository:
    +++git clone https://github.com/kyunkong/vimdotfiles.git $gitdir\n'
    git clone https://github.com/kyunkong/vimdotfiles.git $gitdir
    rcstatus

    echo -e '+++We need to install the vundle first:\n
    +++git clone https://github.com/VundleVim/Vundle.vim.git $gitdir/bundle/Vundle.vim\n'
    git clone https://github.com/VundleVim/Vundle.vim.git $gitdir/bundle/Vundle.vim
    rcstatus

    echo -e '
    \n+++Creating the symbolic links for the rc files\n
    ln -s $gitdir/vimrc ~/.vimrc
    ln -s $dotfiledir/bashrc ~/.bashrc
    ln -s $dotfiledir/inputrc ~/.inputrc
    ln -s $dotfiledir/screenrc ~/.screenrc
    '
    ln -s $gitdir/vimrc ~/.vimrc
    ln -s $dotfiledir/bashrc ~/.bashrc
    ln -s $dotfiledir/inputrc ~/.inputrc
    ln -s $dotfiledir/screenrc ~/.screenrc
    echo -e "+++Install the vundle plugin...\n"
    vim +PluginInstall +qall
    sleep 3
    vim +PluginInstall +qall
    sleep 3
    vim +PluginInstall +qall
    sleep 3

    # Solarized color theme setting
    echo -e '+++Setting up the gnome-terminal:\n
    +++git clone https://github.com/Anthony25/gnome-terminal-colors-solarized.git $gitdir/gnome-terminal-colors-solarized\n
    '
    git clone https://github.com/Anthony25/gnome-terminal-colors-solarized.git $gitdir/gnome-terminal-colors-solarized
    #git clone git@github.com:Anthony25/gnome-terminal-colors-solarized.git $gitdir/gnome-terminal-colors-solarized
    rcstatus

    echo -e "+++Please run the following commands for gnome-terminal Solarized theme\n"
    echo -e '\e[1;31m
    sh $gitdir/gnome-terminal-colors-solarized/set_dark.sh
    eval `dircolors $HOME/.dir_colors/dircolors`
    rm -rf $gitdir/gnome-terminal-colors-solarized/
    \e[0m
    '

    echo -e "+++Installation done...\n"
}


UPDATE(){
    dirstatus
    if [[ $dirstat == 0 ]]; then
        exit 1
    else
        cd $gitdir
        gitstatus
        if [[ $gitstat == 0 ]]; then
            echo -e "+++Would you like to be overwritten by the remote repo?(Y/y or N/n)"
            typeset -u choice
            echo ">"
            read choice
            # echo $choice
            case $choice in
                Y) git reset --hard
                    git pull origin $branch
                    ;;
                N) echo -e "+++Please resolve the conflicts manual and run the script again...\n"
                    exit 1
                    ;;
                *) echo -e "+++Invalid option, please enter Y/y or N/n...\n"
                    # exit 1
                    UPDATE
                    ;;
            esac
        else
            echo -e "+++The local repo is clean, pull repo from remote to local is in action...\n"
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
        echo -e "+++Please enter a commit message here...\n"
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

