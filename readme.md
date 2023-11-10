
[TOC]

## Repo of packing tools

- https://github.com/rainlake/rk2918_tools.git
- https://github.com/neo-technologies/rockchip-mkbootimg

## Vim

### hotkey

```
# switch to split-screen x
<ctrl + w>  w, h, l, j, k
```

### ctags

- ctags-exuberant -f .tags -R .

```
C-], g]		jump to the tag underneath the cursor using the information in the tags file(s)
C-t		jump back up in the tag stack
:tn		jump to next matching tag (If there are multiple matches)
:ts		list all of the definitions of the last tag
```

### cscope

- cscope -Rbkq

### ctrlp

- ctrl + p	open ctrlp
- ctrl + c	close ctrlp

```
f5		更新目录缓存
C-f, C-b	在模式之间切换
C-d		在 "完整路径匹配" 和 "文件名匹配" 之间切换
C-r		在 "字符串模式" 和 "正则表达式模式" 之间切换
C-j, C-k	上下移动光标
C-t		在新的 tab 打开文件
C-v		垂直分割打开
C-x		水平分割打开
C-p, C-n	选择历史记录
C-y		文件不存在时建立文件及目录
C-z		标记/取消标记, 标记多个文件后可使用 <C-o> 同时打开多个文件
```

### vim-bookmarks

```
| Action                                          | Shortcut    | Command                      |
|-------------------------------------------------|-------------|------------------------------|
| Add/remove bookmark at current line             | `mm`        | `:BookmarkToggle`            |
| Add/edit/remove annotation at current line      | `mi`        | `:BookmarkAnnotate <TEXT>`   |
| Jump to next bookmark in buffer                 | `mn`        | `:BookmarkNext`              |
| Jump to previous bookmark in buffer             | `mp`        | `:BookmarkPrev`              |
| Show all bookmarks (toggle)                     | `ma`        | `:BookmarkShowAll`           |
| Clear bookmarks in current buffer only          | `mc`        | `:BookmarkClear`             |
| Clear bookmarks in all buffers                  | `mx`        | `:BookmarkClearAll`          |
| Move up bookmark at current line                | `[count]mkk`| `:BookmarkMoveUp [<COUNT>]`  |
| Move down bookmark at current line              | `[count]mjj`| `:BookmarkMoveDown [<COUNT>]`|
| Move bookmark at current line to another line   | `[count]mg` | `:BookmarkMoveToLine <LINE>` |
| Save all bookmarks to a file                    |             | `:BookmarkSave <FILE_PATH>`  |
| Load bookmarks from a file                      |             | `:BookmarkLoad <FILE_PATH>`  |
```

### tagbar

- :map <C-i> :Tagbar<CR>

```
?		toggle help

CR		jump to tag definition
p		as above, but stay in tagbar window
P		打开一个预览窗口显示标签内容, 如果在标签处回车跳到 vim 编辑页面内定义处, 则预览窗口关闭
C-n		跳到下一个标签页的顶端
C-p		跳到上一个 (或当前) 标签页的顶端
space		底行显示标签原型

*		展开所有标签
=		折叠所有标签
o		在折叠与展开间切换, 按 o 键, 折叠标签
s		切换排序字典
x		是否展开 tagbar 标签栏
```

### bundle respositories

```
# tmux theme
$ git clone https://github.com/jimeh/tmux-themepack

# emacs
$ git clone https://github.com/redguardtoo/emacs.d
$ git reset --hard 77b1ca02

# enhancd
$ git clone https://github.com/babarot/enhancd
$ git reset --hard 5e1541a

# fzf
$ git clone https://github.com/junegunn/fzf
$ git reset --hard f57920a

# YouCompleteMe
$ git clone https://github.com/Valloric/YouCompleteMe
$ git reset --hard 59eea79d

# vim-autoformat
$ git clone --single-branch https://github.com/Chiel92/vim-autoformat
$ git reset --hard db57d84
```

### diff-highlight

```
$ sudo cp /usr/share/doc/git/contrib/diff-highlight/diff-highlight ~/bin/
$ sudo chmod a+x ~/bin/diff-highlight
```

## Keyboard Behavior

*Note: XKB options can be overridden by the tools provided by some desktop environments such as GNOME and KDE.*

- caps lock as ctrl

  - method 1

    Edit the **/etc/default/keyboard** file and include the line

    ```
    ` XKBOPTIONS="ctrl:nocaps"
    ```

    Then, need to reboot or log out and log in again for the changes to take effect.

  - method 2

    In the **/usr/share/X11/xkb/symbols** directory there are various keyboard layouts listed.

    ```
    # To see the actual XKB settings
    $ setxkbmap -print -verbose 10

    # List of XKB options
    $ localectl list-x11-keymap-options | cat
    $ grep -e "ctrl:\|:ctrl" /usr/share/X11/xkb/rules/evdev.lst

    $ setxkbmap -option ctrl:nocaps

    # If you want to replace all previously specified options, use:
    $ setxkbmap -option
    ```

    **GNOME**

    ```
    $ gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:nocaps']"

    $ gsettings get org.gnome.desktop.input-sources xkb-options
    $ gsettings reset org.gnome.desktop.input-sources xkb-options
    ```

  - method 3

    ```
    # To see which keycode corresponds to a key
    $ xev

    # e.g. ~/.Xmodmap
    clear lock
    clear control
    add control = Caps_Lock Control_L Control_R
    keycode 66 = Control_L Caps_Lock NoSymbol NoSymbol

    # To test the changes
    $ xmodmap ~/.Xmodmap

    # Print keymap table as expressions
    $ xmodmap -pke

    $ xmodmap -pm
    ```

## Extra

- dependency packages

```
# ack.vim
$ sudo apt install ack-grep silversearcher-ag
$ sudo apt install cscope exuberant-ctags galculator
```

- shadowsocksr-libev

```
$ git clone https://github.com/shadowsocksr-backup/shadowsocksr-libev
```

- Change python version system-wide with update-alternatives python

```
$ ls -l `which python`*

# To set priority to different versions of the same software
# Python version with the highest priority will be used as the default version
$ sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 10
$ sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.5 20

$ sudo update-alternatives --config python

$ sudo update-alternatives --list python

# To remove
$ sudo update-alternatives --remove python /usr/bin/python3.5
```

- rsyslog

```
# sudo vi /etc/rsyslog.conf
$template m_rsyslog_format, "%$now% %timestamp:8:15%.%timestamp:1:3:date-subseconds% %syslogtag% %msg%\n"
$ActionFileDefaultTemplate m_rsyslog_format

# sudo vi /etc/rsyslog.d/50-default.conf
# - : indicate the use of asynchronous logging
*.*;auth,authpriv.none          -/var/log/syslog

$ sudo systemctl restart rsyslog.service
```

