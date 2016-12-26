#Usage
All the descriptions in the following is included this script
```
/bin/bash <(curl https://raw.githubusercontent.com/Fung920/vimdotfile/master/vim.wrapper.sh)
```

#My first vimrc configure file
I put all my vim relevant configuration files into vimdot directory, and make a soft link,such as:
```bash
#clone to local
git clone https://github.com/Fung920/vimdotfile.git
mv vimdotfile ~/.vim
#update
git pull origin master
cd ~/.vim
cp -rp ~/.bashrc ./bashrc
cp -rp ~/.vimrc ./vimrc
cp -rp ~/.inputrc ./inputrc
#cp -rp ~/.tmux.conf ./tmux.conf
rm -f ~/.inputrc ~/.bashrc ~/.vimrc
ln -s ~/.vim/vimrc ~/.vimrc
ln -s ~/.vim/bashrc ~/.bashrc
ln -s ~/.vim/inputrc ~/.inputrc
#ln -s ~/.vim/tmux.conf ~/.tmux.conf
ln -s ~/.vim/dircolors ~/.dircolors
ln -s ~/.vim/screenrc ~/.screenrc
```


#gitignore collection
[A collection of gitignore templates](https://github.com/github/gitignore)

#solarized color theme in gnome-terminal and vim
- terminal setting

```bash
ln -s ~/.vim/dircolors ~/.dircolors
eval `dircolors ~/.dircolors`
cd ~/.vim/gnome-terminal-colors-solarized
./set_dark.sh
```

- vim setting (it's  already done in vimconfig file)

```vim
if $TERM == "xterm-256color"
set t_Co=256
endif
if $COLORTERM == 'gnome-terminal'
set t_Co=256
endif
let g:solarized_termcolors=16
set background=dark
colorscheme solarized
```

#tmux for ssh 
When using <code>set -g default-terminal "screen-256color"</code> to connect to  remote server which not support screen-256 color, like AIX or SUSE linux, change this line to below will fix this issue:
```bash
set -g default-terminal "xterm"
```

#tmux or screen
For most of Linux/Unix administrators, tmux is not suitable for them, unfortunately, I'm one of them. Screen maybe installed in those production machine while tmux is not. But for me, the most disadvantage for screen is I cannot use mouse to scroll up,to fix this issue, by enabling logging in the screen, when you need to read,copy,paste the output from remote server, the simplest way is to detach the screen session, read the log file, Copy/Paste the output to system clipboard.

tmux and screen cheat-sheet
=======================================
Ctrl in tmux and screen will show as ^ here. My tmux prefix is ^a.

| Action                                                        | Tmux               | Screen                |
|---------------------------------------------------------------|--------------------|-----------------------|
| start a new session                                           | tmux or tmux new   | screen                |
| re-attach a detached session                                  | tmux a             | screen -r             |
| re-attach an attached session(detached it from else where)    | tmux a -d          | screen -dr            |
| re-attach an attached session(keeping it attached elsewhere)  | tmux a             | screen -x             |
| detach from current attached session                          | ^a d               | ^a d                  |
| rename window to a new name                                   | ^a ,               | ^a A                  |
| list windows                                                  | ^a w               | ^a w                  |
| list sessions                                                 | ^a s               | screen -ls            |
| go to  window number                                          | ^a window-number   | ^a window-number      |
| go to last active window                                      | ^a l               | ^a ^a                 |
| go to next window                                             | ^a n               | ^a n                  |
| go to previous window                                         | ^a p               | ^a p                  |
| seek key binding(searching for help)                          | ^a ?               | ^a ?                  |
| create another window                                         | ^a c               | ^a c                  |
| exit or logout current shell/window                           | ^d                 | ^d                    |
| split window horizontal                                       | ^a "               | ^a S                  |
| split window/pan vertical                                     | ^a %               | ^a pipe(vertical bar  |
| next pane                                                     | ^a o               | ^a (tab)              |
| previous pane                                                 | ^a ;               |                       |
| kill current pane                                             | logout OR ^a x     |                       |
| cycle location of panes                                       | ^a ^o              |                       |
| swap current pane with previous                               | ^a {               |                       |
| swap current pane with next                                   | ^a }               |                       |
| show time                                                     | ^a t               |                       |
| show numeric pane number                                      | ^a q               |                       |
| show numeric window number                                    | ^a w               |                       |
| change current pane to a new window                           | ^a !               |                       |
| kill current window                                           | ^a &               |                       |

