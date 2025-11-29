call plug#begin()

" List your plugins here
Plug 'ghomem/nerdtree'
Plug 'ghifarit53/tokyonight-vim'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-fugitive'
Plug 'rodjek/vim-puppet'
Plug 'iberianpig/tig-explorer.vim'
Plug 'mhinz/vim-grepper'

" Uncomment JEDI if you use Python
"Plug 'davidhalter/jedi-vim'

call plug#end()

" Function to toggle terminal
function! ToggleTerminal()

  if exists("g:NERDTreeRoot") && g:NERDTreeRoot.path.str() != ''
    let l:nerdtree_root = g:NERDTreeRoot.path.str()
  else
    let l:nerdtree_root = getcwd()
  endif

  if exists("t:terminal_bufnr") && bufwinnr(t:terminal_bufnr) != -1
    " Terminal exists and is visible, forcefully close it
    execute 'bwipeout! ' . t:terminal_bufnr
    unlet t:terminal_bufnr
  else
    wincmd l
    execute 'lcd' l:nerdtree_root
    if &filetype ==# 'nerdtree'
      wincmd p
    endif
    :terminal
    let t:terminal_bufnr = bufnr('$')
  endif
endfunction

" Function to toggle vertical maximization of the current window
function! ToggleVerticalMaximize()
  if exists('t:winheight')
    " Restore the original window height
    execute t:winheight
    unlet t:winheight
  else
    " Store the current window height
    let t:winheight = 'resize ' . winheight(0)
    " Maximize the window vertically
    resize
  endif

  " If in terminal mode, switch back to Terminal-Insert mode
  if &buftype ==# 'terminal'
    call feedkeys("i")
  endif
endfunction

" NERDTree
"
" focus on file if a file is given as an argument, else focus starts on the tree
" updates CWD as you open a file
" Enter opens the file retaining focus on the tree, sets CWD implicitly
" Space expands a directory, sets CWD
" cd changes PWD and sets CWD for Nerdtree
" Show hidden files by default

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * NERDTree ~/ | if !argc() == 0 || exists('s:std_in') || !v:this_session == '' | :NERDTreeCWD | wincmd p | endif
autocmd FileType nerdtree nmap <buffer> <CR> go
autocmd FileType nerdtree nmap <buffer> <Space> o
autocmd DirChanged * execute 'NERDTreeCWD'
let NERDTreeShowHidden=1

" Vim grepper (results on quickfix window -qf)
"
" Enter on grep results opens the file retaining focus on the result
" q exits the grep results

autocmd FileType qf nnoremap <buffer> <CR> <CR><C-W>p
autocmd FileType qf nnoremap <buffer> q :x<CR>

" Colorscheme
set termguicolors

let g:tokyonight_style = 'night' " available: night, storm
let g:tokyonight_enable_italic = 1

colorscheme tokyonight

" Lightline
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }

" Key mappings
" we include handy Shift + Tab shortcut for circulating through the windows
" it works also in the terminal thanks to tnoremap
nnoremap <silent> <C-Right> <c-w>l
nnoremap <silent> <C-Left> <c-w>h
nnoremap <silent> <C-Up> <c-w>k
nnoremap <silent> <C-Down> <c-w>j
nnoremap <silent> <S-Tab> <c-w>w
tnoremap <S-Tab> <C-w>w

" open tig with current file
" open tig with Project root path
" open tig blame with current file
" but prevent them from working inside NERDTree
" as that messes up the session

nnoremap <expr> <C-t> (&filetype ==# 'nerdtree' ? '' : ':TigOpenCurrentFile<CR>')
nnoremap <expr> <C-y> (&filetype ==# 'nerdtree' ? '' : ':TigOpenProjectRootDir<CR>')
nnoremap <expr> <C-b> (&filetype ==# 'nerdtree' ? '' : ':TigBlame<CR>')

" unmap tig keys as they create awkward situations

let g:tig_explorer_keymap_edit_e  = ''
let g:tig_explorer_keymap_edit    = ''
let g:tig_explorer_keymap_tabedit = ''
let g:tig_explorer_keymap_split   = ''
let g:tig_explorer_keymap_vsplit  = ''

" toggle NERDTree
" toggle line numbers
" toggle terminal maximization


tnoremap <F2> <C-\><C-n>:call ToggleVerticalMaximize()<CR>
tnoremap <F4> <C-\><C-n>:call ToggleTerminal()<CR>
tnoremap <F3> <C-\><C-n>:NERDTreeToggle<CR><c-w>l<c-w>ji

nnoremap <F3> :NERDTreeToggle \| wincmd p<CR>
nnoremap <F4> :call ToggleTerminal()<CR>
nnoremap <F6> :set number!<CR>

" page up goes to scroll mode, moves to the last line and issues page up
" shift+page up/down in scroll mode already behaves like that, so no more mapping needed
" needs in in the end to come back to shell mode
tnoremap <S-PageUp>   <C-W>N1k<C-B>

" recursive search with Control+F
nnoremap <C-f> :GrepperGrep<Space>

" Sync NERDTree with the current vim CWD
let NERDTreeMapCWD='<C-g>'

" Allow the 'q' key to exist the NERDTree context menu (special PR at ghomem/nerdtree)
let NERDTreeMenuQuit='q'

" quit the usual way
nnoremap :q :qa
nnoremap :wq :wqa

" Misc

" uncomment if you want numbers on by default
" set number

" terminal opening
set splitbelow

" default spacing for indentation
set sw=2

" this is somehow necessary for remapping to work reliably
set notimeout

" highlihting the annoying trailing spaces
" the second color is taken from Tokio Night and is the one the gets picked
" when we are running on a Linux desktop environment
highlight ExtraWhitespace ctermbg=red guibg=#ff7a93
match ExtraWhitespace /\s\+$/

" Comment visual selection
xnoremap <leader>c :s/^/#/<CR>

" Uncomment visual selection (removes leading #)
xnoremap <leader>u :s/^#//<CR>
