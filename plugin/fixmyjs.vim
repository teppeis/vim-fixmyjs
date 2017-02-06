"% Preliminary validation of global variables
"  and version of the editor.

if v:version < 700
  finish
endif

" check whether this script is already loaded
if exists('g:fixmyjs_loaded')
  finish
endif

let g:fixmyjs_loaded = 1

if !exists('g:fixmyjs_executables')
  let g:fixmyjs_executables = {}
endif

" Function for debugging
" @param {Any} content Any type which will be converted
" to string and write to tmp file
func! s:console(content)
  let log_dir = fnameescape('/tmp/vimlog')
  call writefile([string(a:content)], log_dir)
  return 1
endfun

" Output warning message
" @param {Any} message The warning message
fun! WarningMsg(message)
  echohl WarningMsg
  echo string(a:message)
endfun

" Output error message
" @param {Any} message The error message
fun! ErrorMsg(message)
  echoerr string(a:message)
endfun

" Common function for fixmyjs
" @param {String} type The type of file js, css, html
" @param {[String]} line1 The start line from which will start
" formating text, by default '1'
" @param {[String]} line2 The end line on which stop formating,
" by default '$'
func! Fixmyjs(...)
  let path = fnameescape(expand("%:p"))
  let eslint = g:fixmyjs_executables.path
  if !executable(eslint)
    eslint = system('PATH=$(npm bin):$PATH && which eslint_d')
    if !executable(eslint)
        " Executable bin doesn't exist
        call ErrorMsg('Neither `eslint` nor `eslint_d` are executable!')
        return 1
    endif
  endif

  let winview = winsaveview()
  let content = join(getline(1,'$'), "\n")
  let result = system(eslint." --fix-to-stdout --stdin --stdin-filename ".path, content)
  silent exec "1,$j"
  let lines = split(result, '\n')
  call setline("1", lines[0])
  call append("1", lines[1:])

  call winrestview(winview)
endfun

command! Fixmyjs call Fixmyjs()
