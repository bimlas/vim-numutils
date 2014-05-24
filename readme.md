NumUtils
========
calculator with regex support

**Please rate if you using it:**
http://www.vim.org/scripts/script.php?script_id=4634

Did you ever want to manipulate a lot of data in text files? Add an offset
to the axes in G-code, calculate the finances, or just renumber the
chapters in the table of contents? With this plugin you can do the
calculations with regular expression support!

Please feel free to send me a mail if you have a good idea, or found a
bug. If you think the plugin does something else that you want, send me
the lines to manipulate, the task that the plugin should do and the
command that you used for, and i try to find and fix the bug.

Examples
--------

`NumUtilsAdd`, `NumUtilsSub`, `NumUtilsMul`, `NumUtilsDiv`

With the built-in commands you can do the basic stuff: addition,
subtraction, multiplication and division. By default the commands
will be called on the line where the cursor stays, but you can use
`:range`, `:global`, or `linewise-visual` to give a range as you do
when you using `:subtitute` for example.

A basic usage is for example add 10 to every number prefixed by `X` on this
line:
```
    X123 Y456 Z789 X100
```
To do it, call this:
```
:NumUtilsAdd 10, 'X'
```
... and you will get this:
```
    X133 Y456 Z789 X110
```

Another example (add 2 to the number after `star_` and to the number after
another number):
```
    .star_10 {
        background: url(stars.png) no-repeat 0 0;
    }

:NumUtilsAdd 2, 'star_!NUM!', ':NUM: !NUM!;$'

    .star_12 {
        background: url(stars.png) no-repeat 0 2;
    }
```
There is another useful feature (add first and second submatch to value of
!NUM!):
```
    100|20|3

:NumUtilsAdd [1,2], '\(:NUM:\)|\(:NUM:\)|!NUM!'

    100|20|123
```

Install
-------

**Manually:**

[Download](https://github.com/BimbaLaszlo/vim-numutils/archive/master.zip)
and unzip the subdirectories into `~/.vim`.

Don't forget to regenerate helptags:
```
:helptags ~/.vim/doc
```

**[Pathogen](https://github.com/tpope/vim-pathogen):**

... into `~/.vim/bundle` (or to your specific pathogen directory).

Don't forget to regenerate helptags:
```
:Helptags
```

**[Vundle](https://github.com/gmarik/Vundle.vim)**:

Add these lines to your `.vimrc` after `call vundle#rc()`:
```
Plugin 'bimbalaszlo/vim-numutils'
```
Open vim again, then call `:PluginInstall`
