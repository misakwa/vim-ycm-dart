if exists('s:initialized')
  finish
endif
let s:initialized = v:true

function! s:FindDart() abort
  if executable('dart') | return resolve(exepath('dart')) | endif
  if executable('flutter')
    let l:flutter = resolve(exepath('flutter'))
    let l:flutter_bin = fnamemodify(l:flutter,':h')
    let l:dart = l:flutter_bin.'/cache/dart-sdk/bin/dart'
    if executable(l:dart) | return l:dart | endif
  endif
  echoerr 'Could not find a `dart` executable'
endfunction

function! s:FindCommand() abort
    let l:dart = s:FindDart()
    if type(l:dart) != type('') | return v:null | endif
    let l:bin = fnamemodify(l:dart, ':h')
    let l:snapshot = l:bin.'/snapshots/analysis_server.dart.snapshot'
    if !filereadable(l:snapshot)
        echoerr 'Could not find analysis server snapshot at '.l:snapshot
        return v:null
    endif
    let l:cmd = [l:dart, l:snapshot, '--lsp']
    let l:sdk_root = fnamemodify(l:bin, ':h')
    let l:language_model = l:sdk_root.'/model/lexeme'
    if isdirectory(l:language_model)
        call add(l:cmd, '--completion-model='.l:language_model)
    endif
    return l:cmd
endfunction

function! s:RegisterDartServer() abort
    let l:command = s:FindCommand()
    if type(l:command) == type(v:null) | return | endif
    let l:ycm_language_server = get(g:, 'ycm_language_server', [])
    let l:ycm_language_server += [{'name': 'dart', 'cmdline': l:command, 'filetypes': ['dart'] }]
    let g:ycm_language_server = l:ycm_language_server
endfunction

call s:RegisterDartServer()
