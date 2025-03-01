" Configuration test runner
" For testing configuration modules

" Set up test mode
let g:_test_mode = 1
let g:_test_verbose = get(g:, '_test_verbose', 0)

" Define a function to run tests
function! RunConfigTests()
  " Load the lua test runner and run config tests
  lua << EOF
  -- Run configuration tests
  local test_runner = require('tests.run_tests')
  
  -- Load config tests with relative path
  test_runner.run_tests('tests/spec')
EOF
endfunction

" Run the tests
call RunConfigTests()