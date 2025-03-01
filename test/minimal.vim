" Minimal Neovim config for testing
" Based on laravel-helper plugin's minimal.vim

" Set runtime path to include only the core runtime and current directory
set runtimepath=$VIMRUNTIME
let &packpath = &runtimepath

" Add the config directory to runtimepath
let s:config_path = expand('~/.config/nvim')
let &runtimepath = &runtimepath . ',' . s:config_path

" Ensure we're using the correct directories in tests
let s:test_dir = expand('~/.config/nvim/test')
let s:tests_dir = expand('~/.config/nvim/tests')

" Disable features not needed for testing
let g:loaded_node_provider = 0
let g:loaded_python3_provider = 0
let g:loaded_ruby_provider = 0
let g:loaded_perl_provider = 0

" Enable testing mode
let g:_test_mode = 1

" Basic settings
set noswapfile
set nobackup
set termguicolors

" This ensures we can run headless tests
set shortmess+=I
set nomore

" Load the Lua-based test init
lua require('tests.minimal-init')