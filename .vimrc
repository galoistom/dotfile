" -------------------------------
" 插件声明 (必须放在文件开头)
" -------------------------------
call plug#begin()
Plug 'mhinz/vim-startify'
Plug 'airblade/vim-rooter'

" 代码分析
Plug 'dense-analysis/ale'
Plug 'bfrg/vim-cpp-modern'


Plug 'neoclide/coc.nvim', {'branch':'realese'}
Plug 'preservim/nerdtree'
Plug 'jiangmiao/auto-pairs'
Plug 'MattesGroeger/vim-bookmarks'    
Plug 'azabiong/vim-highlighter'       
Plug 'dhruvasagar/vim-table-mode'    
Plug 'junegunn/vim-easy-align'        
Plug 'modulomedito/rookie_toys.vim'   " Hex, clangd, gitgraph, others
Plug 'roginfarrer/vim-dirvish-dovish' " Keymap for file browser
Plug 'sainnhe/everforest'             " Colorscheme
Plug 'skywind3000/asyncrun.vim'       " Asynchronously run
Plug 't9md/vim-textmanip'             " Text movement
Plug 'tpope/vim-commentary'           " Comment out
Plug 'tpope/vim-fugitive'             " Git integration
Plug 'tpope/vim-surround'             " Surroud word with char
Plug 'tpope/vim-unimpaired'           " Efficient keymaps
Plug 'vim-airline/vim-airline'        " Vim bottom status line
Plug 'vim-airline/vim-airline-themes' " Vim bottom status line
Plug 'vim-scripts/DrawIt'             " Draw ASCII art
call plug#end()

" -------------------------------
" 基础设置
" -------------------------------
"set statusline=%F\ %y\ %m\ %r\ %{strftime('%c')}
set number                " 显示行号
syntax on                 " 语法高亮
set background=dark
set relativenumber
" Tab 配置
set shiftwidth=4          " 自动缩进宽度
set softtabstop=4         " 插入模式 Tab 宽度
set expandtab             " 用空格替代 Tab（若需真实 Tab 则注释此行）
set smartindent         " 启用智能缩进
set autoindent          " 自动缩进
"set noexpandtab          " 使用真实 Tab（取消注释启用）
set guicursor=n:block,i:ver1,r:hor20,v:block,c:block,sm:block
set mouse=a
"colorscheme sorbet
let g:NERDTreeKeepTreeInSync = 1
set clipboard=unnamedplus
set cursorline
hi NORMAL ctermbg=NONE guibg=NONE
hi NOTEXT ctermbg=NONE guibg=NONE
set ignorecase          " 搜索时忽略大小写
set smartcase           " 当搜索包含大写字母时，大小写敏感
set list
set listchars=tab:»·,trail:·
"set showmatch
highlight Search ctermfg=white ctermbg=blue
" -------------------------------
" 快捷键绑定
" -------------------------------
let mapleader = "\<Space>"
nnoremap <leader>t :belowright term<CR>
nnoremap <leader>e :NERDTreeToggle %:p:h<CR>
nnoremap <leader>w <C-w>
nnoremap <S-Tab> :bp<CR>
nnoremap <Tab> :bn<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>Q :wq<CR>
nnoremap <leader>E :Explore<CR>
nnoremap <leader>s :w<CR>
nnoremap H ^
nnoremap L %
inoremap <expr> <C-j> coc#pum#visible() ? coc#pum#next(1) : "\<C-j>"
inoremap <expr> <C-k> coc#pum#visible() ? coc#pum#prev(1) : "\<C-k>"
inoremap <expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
" 运行 Python
nnoremap <F4> :w<CR>:term python %<CR>  
" 运行 C++
nnoremap <F5> :w<CR>:!konsole -e bash -c "gcc %:p -o %:p:r && %:p:r; read"<CR>
nnoremap <ESC> :nohl<CR>

" =======================================
" vim-startify 配置
" =======================================
"colorscheme desert
let g:startify_enable_special = 1

" 自定义 Header (例如 ASCII 艺术或欢迎语)
let g:startify_custom_header = [
    \ ' _   _              _           _    ',
    \ '| | | | ___ _   _  | | __ _ ___| | __',
    \ '| |_| |/ _ \ | | | | |/ _` / __| |/ /',
    \ '|  _  |  __/ |_| | | | (_| \__ \   < ',
    \ '|_| |_|\___|\__, | |_|\__,_|___/_|\_\',
    \ '            |___/                     ',
    \ '',
    \ '       Welcome to Vim!                ',
    \ ]

let g:startify_bookmarks = [
    \ { 'Config': '~/.vimrc' },
    \ { 'Plugins': '~/.vim/plugged/' },
    \ { 'My Project': '~/Projects/my_awesome_project/' },
    \ { 'Help': ':h startify<CR>' } 
    \ ]

let g:startify_custom_sections = [
    \ '         _.--.           .--._',
    \ '       ( M.R.U.S.I.N.S. )',
    \ '         `--`           `--`',
    \ '',
    \ { 'type': 'header',    'header': g:startify_custom_header, 'align': 'center' },
    \ { 'type': 'buttons',   'header': ['  Quick Actions:'],
    \     'commands': [
    \         ['<leader>e', 'New Empty Buffer', 'ene'],
    \         ['<leader>f', 'Find File (FZF)', 'Files<CR>'],
    \         ['<leader>o', 'Open Recent', 'oldfiles<CR>'],
    \         ['<leader>q', 'Quit Vim', 'qa'],  
    \     ],
    \ 'align': 'center' },  
    \ { 'type': 'mru',       'header': ['   Recent Files:'], 'align': 'center' },
    \ { 'type': 'bookmarks', 'header': ['   Bookmarks:'], 'size': 5, 'align': 'center' },
    \ { 'type': 'dir',       'header': ['   Recent Dirs:'], 'size': 5, 'align': 'center' },
    \ { 'type': 'sessions',  'header': ['   Sessions:'], 'size': 5, 'align': 'center' },
    \ { 'type': 'footer',    'header': ['  ' . strftime('%A, %B %d, %Y')], 'align': 'center' }
    \ ]  

" 设置启动 Vim 时自动显示 Startify (如果不是打开文件)
autocmd VimEnter * if !argc() | Startify | endif

" 也可以设置快捷键随时打开
nnoremap <leader>h :Startify<CR>

set omnifunc=syntaxcomplete#Complete
