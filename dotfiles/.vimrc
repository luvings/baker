" first,
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line

" Customized
Bundle 'morhetz/gruvbox'
Bundle 'scrooloose/nerdtree'
Bundle 'taglist.vim'
Bundle 'majutsushi/tagbar'
Bundle 'jeetsukumaran/vim-buffergator'
Bundle 'scrooloose/nerdcommenter'
Bundle 'terryma/vim-multiple-cursors'
Bundle 'godlygeek/tabular'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'mileszs/ack.vim'
Bundle 'ctrlpvim/ctrlp.vim'

Plugin 'Valloric/YouCompleteMe'
Plugin 'preservim/vimux'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'Chiel92/vim-autoformat'
Plugin 'wincent/command-t'
Plugin 'MattesGroeger/vim-bookmarks'
Plugin 'lifepillar/vim-cheat40'
" End Customized

call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" which plugin has set the tabstop?
" :verbose set tabstop

syntax on
set tabstop=8
"set expandtab
set softtabstop=-1
set shiftwidth=8
set backspace=indent,eol,start
set vb t_vb=
"set paste

set autoindent
set cindent
set smartindent
set number
set hlsearch
set incsearch
set nohls
set showmatch
set noautochdir
set wildmenu

set tags=.tags
set wildignore+=*.o,*.so,*/Documentation/*,*/.git

set fileencoding=utf-8
set encoding=utf-8
"set fencs=utf-8,gbk,gb2312,gb18030
"set fileencodings=utf-8,gb2312,gb18030,gbk,ucs-bom,cp936,latin1

set fdm=indent
set foldlevelstart=99
"set clipboard=unnamedplus

" background
colorscheme gruvbox
"let g:gruvbox_termcolors=16

set background=dark
set guioptions=
set cursorline
"set cursorcolumn

" The <leader> key is mapped to '\' by default
let mapleader=","

" table
set stal=2
set t_Co=256
set showtabline=2
set laststatus=2
set statusline=%{CurDir()}
set tabline=%!MTabLine()
highlight TabNum ctermfg=White ctermbg=2
highlight TabLineSel term=bold cterm=bold ctermbg=Red ctermfg=Yellow
highlight TabLine ctermfg=Yellow ctermbg=DarkGray

" taglist
"let Tlist_Auto_Open=1
let Tlist_Use_Right_Window=0
let Tlist_File_Fold_Auto_Close=1
let Tlist_Close_On_Select=1
let Tlist_Exit_OnlyWindow=1
let Tlist_Use_SignleClick=1
let Tlist_Enable_Fold_Column=0
let Tlist_WinWidth=60
let Tlist_Inc_Winwidth=0
let Tlist_Ctags_Cmd='/usr/bin/ctags-exuberant'

" tagbar
" <ctrl + w> w, h, l
let g:tagbar_width=60
let g:tagbar_left=1
let g:tagbar_autoclose=1
let g:tagbar_ctags_bin='/usr/bin/ctags-exuberant'
"autocmd BufReadPost *.cpp,*.c,*.h,*.hpp,*.cc,*.cxx call tagbar#autoopen()

" nerdtree
let NERDChristmasTree=0
let NERDTreeDirArrows=0
let NERDTreeWinSize=60
let NERDTreeQuitOnOpen=1

" buffergator
let g:buffergator_vsplit_size=80
let g:buffergator_show_new_tab=1

" vim-bookmarks
let g:bookmark_sign = '>>'
let g:bookmark_annotation_sign = '##'
let g:bookmark_show_warning = 0
let g:bookmark_auto_save = 0
"let g:vbookmark_bookmarkSaveFile = $HOME . '/.vimbookmark'
highlight BookmarkSign ctermbg=blue ctermfg=white guifg=white guibg=RoyalBlue3
highlight BookmarkAnnotationSign ctermbg=DarkGray ctermfg=yellow

" YouCompleteMe
let g:ycm_python_binary_path = '/usr/bin/python'
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
let g:ycm_show_diagnostics_ui = 0
let g:ycm_confirm_extra_conf=0
let g:ycm_collect_identifiers_from_tags_files=1
let g:ycm_collect_identifiers_from_comments_and_strings = 0
let g:ycm_cache_omnifunc=0
let g:ycm_seed_identifiers_with_syntax=1
let g:ycm_complete_in_comments = 1
let g:ycm_complete_in_strings = 1

let g:ycm_filetype_blacklist = {
            \ 'tagbar' : 1,
            \ 'nerdtree' : 1,
            \}
let g:ycm_semantic_triggers =  {
            \ 'c,cpp,python,java,go,erlang,perl':['re!\w{2}'],
            \ 'cs,lua,javascript':['re!\w{2}'],
            \}

set completeopt=longest,menu
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

"inoremap <expr> <CR>       pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <expr> <PageDown> pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<PageDown>"
inoremap <expr> <PageUp>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<PageUp>"

nnoremap <leader>jd :YcmCompleter GoToDefinitionElseDeclaration<CR>
"inoremap <leader><leader> <C-x><C-o>

" nerdcommenter
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1
" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" vim-multiple-cursors
let g:multi_cursor_use_default_mapping=0
let g:multi_cursor_next_key='<C-m>'
let g:multi_cursor_prev_key='<C-p>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<Esc>'

" easymotion
let g:EasyMotion_smartcase = 1
map <leader><leader>w <Plug>(easymotion-w)
map <leader><leader>b <Plug>(easymotion-b)
map <leader><leader>s <Plug>(easymotion-s)
map <leader><leader>h <Plug>(easymotion-linebackward)
map <leader><leader>j <Plug>(easymotion-j)
map <leader><leader>k <Plug>(easymotion-k)
map <leader><leader>l <Plug>(easymotion-lineforward)
map <leader><leader>. <Plug>(easymotion-repeat)

" ack
let g:ackprg = 'ag --nogroup --nocolor --column'

" autoformat
let g:autoformat_verbosemode=1
"au BufWrite * :Autoformat

let g:formatdef_allman = '"indent -npro -kr -i8 -ts8 -sob -l140 -ss -ncs -cp1"'
"let g:formatdef_allman = '"astyle --style=kr --pad-oper --pad-header --align-pointer=name --indent=tab=8 --break-after-logical --unpad-paren --indent-col1-comments --attach-return-type-decl --attach-return-type --suffix=none --break-blocks=all --max-code-length=140 --recursive"'
let g:formatters_cpp = ['allman']
let g:formatters_c = ['allman']

" ctrlp
let g:ctrlp_map = '<c-p>'
let g:ctrlp_clear_cache_on_exit = 1

" command-t
let g:CommandTMaxFiles=50000
let g:SuperTabDefaultCompletionType="context"
let g:CommandTMatchWindowReverse=1
":map <slient> <C-k> <C-w>gf :tabm 999
":map <C-k> <C-w>gf
":map <M-1> 1gt
":map <M-2> 2gt
":map <M-0> :tablast<CR>

:map <C-i> :Tagbar<CR>
:map <C-l> :NERDTreeFind<CR>
":map <C-k> :VbookmarkListAll<CR>
:map <C-k> :BookmarkShowAll<CR>
:map <C-n> :BuffergatorTabsOpen<CR>
:map <C-p> :TlistOpen<CR>
:map <C-y> :tabedit<space>

noremap <leader>R :!ctags-exuberant -f .tags -R<CR>
noremap <F2> :Autoformat<CR>:w<CR>
noremap <F4> :Ack!<space>
" normal, non-recursive mode
nnoremap ff :CtrlP<space>

" :help vimux
" Prompt for a command and run it
noremap <leader>vp :VimuxPromptCommand<CR>
" Run the last command
noremap <leader>vl :VimuxRunLastCommand<CR>
" Inspect runner pane map
noremap <leader>vi :VimuxInspectRunner<CR>
" Close the tmux runner
noremap <leader>vq :VimuxCloseRunner<CR>

autocmd FileType make set noexpandtab
autocmd FileType kconfig set noexpandtab
autocmd FileType dts set noexpandtab
autocmd FileType * setl fo-=cr
"autocmd VimEnter * ConqueTermTab bash

" Open a file to automatically locate the last exit
if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

function CurDir()
    let curdir = substitute(getcwd(), $HOME, "~", "g")
    let curname = expand("%f%m%r%h")

    let full = ' '
    let full .= curname
    let full .= ' | '

    let fullLength = strlen(full)
    let dirLength = strlen(curdir)
    let statLength = &columns

    if statLength < dirLength + fullLength
        let droplen = dirLength + fullLength - statLength
        if droplen < dirLength
            let curdir = strpart(curdir,droplen)
        else
            let curdir = ''
        endif
    endif

    let full .= curdir

    return full
endfunction

function MTabLine()
    let s = ''
    let t = tabpagenr()

    let i = 1
    let fileNameLength = 0
    while i <= tabpagenr('$')
        let buflist = tabpagebuflist(i)
        let winnr = tabpagewinnr(i)
        let file = bufname(buflist[winnr - 1])
        let file = fnamemodify(file, ':p:t')
        if file == ''
            let file = '[No Name]'
        endif
        let fileNameLength = fileNameLength + strlen(file) + 3
        let i = i + 1
    endwhile

    let needShort = 0
    let needShowFileName = 1
    let tabline_width = &columns
    if fileNameLength > tabline_width
        "let extraStrNum = fileNameLength - tabline_width
        let maxLengthPerFile = tabline_width / (i - 1)
        let needShort = 1
        if maxLengthPerFile <= 3
            let needShowFileName = 0
        endif
    endif

    let i = 1
    while i <= tabpagenr('$')
        let buflist = tabpagebuflist(i)
        let winnr = tabpagewinnr(i)
        let s .= '%' . i . 'T'
        let s .= (i == t ? '%1*' : '%2*')
        let s .= ' '
        let s .= '%#TabNum#'
        let s .= i . ' '
        let s .= '%*'
        let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')

        if needShowFileName == 1
            let file = bufname(buflist[winnr - 1])
            let file = fnamemodify(file, ':p:t')
            if file == ''
                let file = '[No Name]'
            endif
            if needShort == 1
                let fileNameLenght = strlen(file)
                if fileNameLenght > (maxLengthPerFile - 3)
                    let file = strpart(file,fileNameLenght + 3 - maxLengthPerFile)
                endif
            endif

            let s .= file
        endif
        let i = i + 1
    endwhile

    let s .= '%T%#TabLineFill#%='
    "let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
    return s
endfunction

if has("cscope")
    set csprg=/usr/bin/cscope
    " set csto=0: search cscope database first, then search for .tags file
    set csto=0
    " set cst: use ':cs find g' to search
    set cst
    set nocsverb
    " add any database in current directory
    if filereadable("cscope.out")
        cs add cscope.out
        " else add database pointed to by environment
    elseif $CSCOPE_DB != ""
        cs add $CSCOPE_DB
    endif
    set csverb
    "set cscopequickfix=s-!,c-!,d-,i-,t-,e-,f-,g-!
    "set cscopequickfix=s-!,c-!,d-!,i-!,t-!,e-!,f-!,g-!
    "autocmd QuickFixCmdEnd * exe "cw"
endif

"
" The following maps all invoke one of the following cscope search types:
"
"   's'   symbol: find all references to the token under cursor
"   'g'   global: find global definition(s) of the token under cursor
"   'c'   calls:  find all calls to the function name under cursor
"   't'   text:   find all instances of the text under cursor
"   'e'   egrep:  egrep search for the word under cursor
"   'f'   file:   open the filename under cursor
"   'i'   includes: find files that include the filename under cursor
"   'd'   called: find functions that function under cursor calls
"
" Below are three sets of the maps: one set that just jumps to your
" search result, one that splits the existing vim window horizontally and
" diplays your search result in the new window, and one that does the same
" thing, but does a vertical split instead (vim 6 only).
"
" I've used CTRL-\ and CTRL-@ as the starting keys for these maps, as it's
" unlikely that you need their default mappings (CTRL-\'s default use is
" as part of CTRL-\ CTRL-N typemap, which basically just does the same
" thing as hitting 'escape': CTRL-@ doesn't seem to have any default use).
" If you don't like using 'CTRL-@' or CTRL-\, , you can change some or all
" of these maps to use other keys.  One likely candidate is 'CTRL-_'
" (which also maps to CTRL-/, which is easier to type).  By default it is
" used to switch between Hebrew and English keyboard mode.
"
" All of the maps involving the <cfile> macro use '^<cfile>$': this is so
" that searches over '#include <time.h>" return only references to
" 'time.h', and not 'sys/time.h', etc. (by default cscope will return all
" files that contain 'time.h' as part of their name).


" To do the first type of search, hit 'CTRL-\', followed by one of the
" cscope search types above (s,g,c,t,e,f,i,d).  The result of your cscope
" search will be displayed in the current window.  You can use CTRL-T to
" go back to where you were before the search.
"
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :cs find f <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>i :cs find i <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>s :cs find s <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
