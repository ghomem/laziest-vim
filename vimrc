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

" ##### Configuration #####

let g:max_visible_buffers = 4

" ##### Functions #####

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

" Resize first visible terminal window by {delta} lines
function! s:ResizeTerminal(delta) abort
  let curwin = winnr()

  " Find a visible terminal window
  for w in range(1, winnr('$'))
    if getbufvar(winbufnr(w), '&buftype') ==# 'terminal'
      execute w . 'wincmd w'
      execute 'resize ' . (a:delta > 0 ? '+' : '') . a:delta
      execute curwin . 'wincmd w'
      return
    endif
  endfor
endfunction

function! LightlineBufferTabs()

  " Find the visible buffers
  let l:visible_buffers = s:GetVisibleBuffers()

  " Resort them by their buffer ID so they don't jump around randomly on screen
  call sort(l:visible_buffers, {a, b -> a - b})

  " Render them onto the tabline
  let l:current = bufnr('%')

  " FIX: If inside NERDTree, find which of our visible buffers was used most recently
  if &filetype ==# 'nerdtree'
    " Since visible_buffers is sorted by buffer ID in step 4, let's find the one
    " that has the highest 'lastused' timestamp to identify the active file.
    let l:most_recent = l:visible_buffers[0]
    for l:b in l:visible_buffers
      if getbufinfo(l:b)[0].lastused > getbufinfo(l:most_recent)[0].lastused
        let l:most_recent = l:b
      endif
    endfor
    let l:current = l:most_recent
  endif

  let l:result = ''
  for l:bufnr in l:visible_buffers
    let l:name = bufname(l:bufnr)
    let l:name = (l:name == '') ? '[No Name]' : fnamemodify(l:name, ':t')

    if l:bufnr == l:current
      let l:result .= '[' . l:name . '] '
    else
      let l:result .= ' ' . l:name . '  '
    endif
  endfor

  return l:result
endfunction

function! s:GetVisibleBuffers()
  let l:blist = filter(range(1, bufnr('$')), 'buflisted(v:val)')
  call sort(l:blist, {a, b -> getbufinfo(a)[0].lastused - getbufinfo(b)[0].lastused})
  let l:start = len(l:blist) > g:max_visible_buffers ? len(l:blist) - g:max_visible_buffers : 0
  let l:visible = l:blist[l:start : ]
  call sort(l:visible, {a, b -> a - b})
  return l:visible
endfunction

function! SmartBufferNext()
  let l:visible = s:GetVisibleBuffers()
  let l:idx = index(l:visible, bufnr('%'))
  let l:next_idx = l:idx != -1 ? (l:idx + 1) % len(l:visible) : -1
  execute 'buffer ' . l:visible[l:next_idx]
endfunction

function! SmartBufferPrev()
  let l:visible = s:GetVisibleBuffers()
  let l:idx = index(l:visible, bufnr('%'))
  let l:prev_idx = l:idx != -1 ? (l:idx - 1 + len(l:visible)) % len(l:visible) : -1
  execute 'buffer ' . l:visible[l:prev_idx]
endfunction

" ##### NERDTree #####
"
" focus on file if a file is given as an argument, else focus starts on the tree
" updates CWD as you open a file
" Enter opens the file retaining focus on the tree, sets CWD implicitly
" Space expands a directory, sets CWD
" cd changes PWD and sets CWD for Nerdtreea - PENDING
" Show hidden files by default

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * NERDTree | if !argc() == 0 || exists('s:std_in') || !v:this_session == '' | :NERDTreeCWD | wincmd p | endif
autocmd FileType nerdtree nmap <buffer> <CR> go
autocmd FileType nerdtree nmap <buffer> <Space> o

autocmd FileType nerdtree nmap <buffer> <M-Up> u
autocmd FileType nerdtree nmap <buffer> <M-Right> C

" this would be nice but it makes the tig plugin fail in the first launch
"autocmd DirChanged * execute 'NERDTreeCWD'

let NERDTreeChDirMode=2

let NERDTreeShowHidden=1

" Sync NERDTree with the current vim CWD
let NERDTreeMapCWD='<C-g>'

" Allow the 'q' key to exist the NERDTree context menu (special PR at ghomem/nerdtree)
let NERDTreeMenuQuit='q'


" ##### Vim grepper #####
"
" Results appear on the quickfix window -qf
"
" Enter on grep results opens the file retaining focus on the result
" q exits the grep results

autocmd FileType qf nnoremap <buffer> <CR> <CR><C-W>p
autocmd FileType qf nnoremap <buffer> q :x<CR>


" ##### Colorscheme #####
set termguicolors

let g:tokyonight_style = 'night' " available: night, storm
let g:tokyonight_enable_italic = 1

colorscheme tokyonight

" improve contrast on the NERDTree selected line
" this is standard color 237 which will be used by tig
" in the highlighted lines
highlight CursorLine guibg=#3a3a3a

let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'tabline': {
      \   'left': [ [ 'my_buffers' ] ],
      \   'right': [ [ 'close' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead',
      \   'my_buffers': 'LightlineBufferTabs'
      \ }
      \ }

" Always show the top tabline
set showtabline=2

" Forces lightline to rebuild the tabline every time a buffer is added,
" deleted, or entered.
augroup LightlineBufferGroup
  autocmd!
  autocmd BufEnter,BufAdd,BufDelete,BufWinEnter * call lightline#update()
augroup END


" ##### General key mappings #####
"
" we include handy Shift + Tab shortcut for circulating through the windows
" it works also in the terminal thanks to tnoremap
nnoremap <silent> <C-Right> <c-w>l
nnoremap <silent> <C-Left> <c-w>h
nnoremap <silent> <C-Up> <c-w>k
nnoremap <silent> <C-Down> <c-w>j
nnoremap <silent> <S-Tab> <c-w>w
tnoremap <S-Tab> <C-w>w

 " Cycle to the next/previous buffer with Ctrl + n/p

nnoremap <expr> <C-n> (&filetype ==# 'nerdtree' ? '' : ":call SmartBufferNext()\<CR>")
nnoremap <expr> <C-p> (&filetype ==# 'nerdtree' ? '' : ":call SmartBufferPrev()\<CR>")

" let the normal shorcuts also work from the terminal
tnoremap <silent> <C-Up> <c-w>k
tnoremap <silent> <C-Left> <c-w>h

" open tig with current file
" open tig with Project root path
" open tig blame with current file
" but prevent them from working inside NERDTree
" as that messes up the session

nnoremap <expr> <C-t> (&filetype ==# 'nerdtree' ? '' : ':TigOpenCurrentFile<CR>')
nnoremap <expr> <C-y> (&filetype ==# 'nerdtree' ? '' : ':TigOpenProjectRootDir<CR>')
nnoremap <expr> <C-b> (&filetype ==# 'nerdtree' ? '' : ':TigBlame<CR>')

" unmap tig keys as they create awkward situations
" the first assignement is dummy, it removes a shell warning
" caused by the tig explorer bash installer

let g:tig_explorer_keymap_edit_e  = 'e'
let g:tig_explorer_keymap_edit    = ''
let g:tig_explorer_keymap_tabedit = ''
let g:tig_explorer_keymap_split   = ''
let g:tig_explorer_keymap_vsplit  = ''

" toggle NERDTree
" toggle line numbers
" toggle terminal maximization
" resize terminal

tnoremap <F3> <C-\><C-n>:NERDTreeToggle<CR><c-w>l<c-w>ji
tnoremap <F2> <C-\><C-n>:call ToggleVerticalMaximize()<CR>
tnoremap <F4> <C-\><C-n>:call ToggleTerminal()<CR>

" Resize terminal from any window
nnoremap <S-Up>   :call <SID>ResizeTerminal(+1)<CR>
nnoremap <S-Down> :call <SID>ResizeTerminal(-1)<CR>

" Resize terminal from the terminal
tnoremap <S-Up>   <C-\><C-n>:resize +1<CR>i
tnoremap <S-Down> <C-\><C-n>:resize -1<CR>i

nnoremap <F3> :NERDTreeToggle \| wincmd p<CR>
nnoremap <F4> :call ToggleTerminal()<CR>
nnoremap <F6> :set number!<CR>

" Vim help from F1 also exits with q
autocmd FileType help nnoremap <buffer> q :x<CR>

" page up goes to scroll mode, moves to the last line and issues page up
" shift+page up/down in scroll mode already behaves like that, so no more mapping needed
" needs in in the end to come back to shell mode
tnoremap <S-PageUp>   <C-W>N1k<C-B>

" recursive search with Control+F
nnoremap <C-f> :GrepperGrep<Space>

" Comment visual selection
xnoremap <leader>c :s/^/#/<CR>

" Uncomment visual selection (removes leading #)
xnoremap <leader>u :s/^#//<CR>
" quit the usual way
nnoremap :q :qa
nnoremap :wq :wqa

" ##### Misc settings #####

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

" clean trailing spaces
nnoremap <C-x> :%s/\s\+$//e<CR>

