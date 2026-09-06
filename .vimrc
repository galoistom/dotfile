" -------------------------------
" 基础设置
" -------------------------------

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
set listchars=tab:»·
set smartindent
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
inoremap ( ()<Left>
inoremap [ []<Left>
inoremap { {}<Left>
inoremap " ""<Left>
inoremap ' ''<Left>
" 运行 Python
nnoremap <F4> :w<CR>:term python %<CR>  
" 运行 C++
nnoremap <ESC> :nohl<CR>

" =======================================
" vim-startify 配置
" =======================================
"colorscheme desert
let g:startify_enable_special = 1

