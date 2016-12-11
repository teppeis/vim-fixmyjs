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

if !exists('g:fixmyjs_config')
  let g:fixmyjs_config = {}
endif

if !exists('g:fixmyjs_executable')
    let g:fixmyjs_executable = 'eslint_d'
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
  let winview = winsaveview()
  let path = fnameescape(expand("%:p"))
  let content = join(getline(1,'$'), "\n")

  let g:fixmyjs_executable = expand(g:fixmyjs_executable)
  if executable(g:fixmyjs_executable)
    let result = system(g:fixmyjs_executable." --fix-to-stdout -f unix --stdin --stdin-filename ".path, content)
    silent exec "1,$j"
    let lines = split(result, '\n')
    call setline("1", lines[0])
    call append("1", lines[1:])
  else
    " Executable bin doesn't exist
    call ErrorMsg('The '.g:fixmyjs_executable.' is not executable!')
    return 1
  endif

  call winrestview(winview)
endfun

command! Fixmyjs call Fixmyjs()
