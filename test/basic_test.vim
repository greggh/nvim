" Basic test runner
" Similar to laravel-helper plugin's test runner

" Set up test mode
let g:_test_mode = 1
let g:_test_verbose = get(g:, '_test_verbose', 0)

" Define a function to run tests
function! RunBasicTests()
  " Load the lua test runner with relative path
  lua require('tests.run_tests').run_tests('tests/spec')
endfunction

" Run the tests
call RunBasicTests()