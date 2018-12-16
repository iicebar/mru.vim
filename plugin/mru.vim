" vim:set ts=4 sts=2 sw=2 tw=0 et:
" File: mru.vim
" Author: Yegappan Lakshmanan (yegappan AT yahoo DOT com)
" Version: 3.3-i5
" Last Modified: December 18, 2009
" Copyright: Copyright (C) 2003-2009 Yegappan Lakshmanan
"            Permission is hereby granted to use and distribute this code,
"            with or without modifications, provided that this copyright
"            notice is copied with it. Like anything else that's free,
"            mru.vim is provided *as is* and comes with no warranty of any
"            kind, either expressed or implied. In no event will the copyright
"            holder be liable for any damamges resulting from the use of this
"            software.
"
" Modified:Arakawa, Tomoaki
"
" Overview
" --------
" The Most Recently Used (MRU) plugin provides an easy access to a list of
" recently opened/edited files in Vim. This plugin automatically stores the
" file names as you open/edit them in Vim.
"
" This plugin will work on all the platforms where Vim is supported. This
" plugin will work in both console and GUI Vim. This version of the MRU
" plugin needs Vim 7.0 and above. If you are using an earlier version of
" Vim, then you should use an older version of the MRU plugin.
"
" The recently used filenames are stored in a file specified by the Vim
" MRU_File variable.
"
" Configuration
" -------------
"
if exists('s:loaded_mru')
  finish
endif
let s:loaded_mru=1

if v:version < 700
  finish
endif

" Func:Env {{{1
function! s:MRU_Env_Var() " {{{2
  " Common Settings {{{3
 
  " Maximum number of entries allowed in the MRU list
  if !exists('g:MRU_Max_Entries')
    let g:MRU_Max_Entries = 500
  endif

  " Height of the MRU window
  if !exists('g:MRU_Window_Height')
    let g:MRU_Window_Height = 8
  endif

  if !exists('g:MRU_Auto_Close')
    let g:MRU_Auto_Close = 1
  endif

  if !exists('g:MRU_Use_CursorLine')
    let g:MRU_Use_CursorLine = 1
  endif

  if !exists('g:MRU_Use_StartupCheck_FileReadable')
    let g:MRU_Use_StartupCheck_FileReadable = 0
  endif

  if !exists('g:MRU_Max_AddInfoLength')
    let g:MRU_Max_AddInfoLength = 40
  endif

  if !exists('g:MRU_Use_Keymap_Execute_Msg')
    let g:MRU_Use_Keymap_Execute_Msg = 1
  endif
  " }}}3
  " Mru File {{{3
  " Files to exclude from the MRU list
  if !exists('g:MRU_Exclude_Files')
    if has('win32')
      let g:MRU_Exclude_Files = '^c:\\temp\\.*'           " For MS-Windows
    elseif has('mac')
      let g:MRU_Exclude_Files = '^/tmp/.*\|^/var/tmp/.*|^.*/var/folders/.*Tmp.*'  " For Mac
    elseif has('unix')
      let g:MRU_Exclude_Files = '^/tmp/.*\|^/var/tmp/.*'  " For Unix
    else
      let g:MRU_Exclude_Files = ''
    endif
  endif

  " Files to include in the MRU list
  if !exists('g:MRU_Include_Files')
    let g:MRU_Include_Files = ''
  endif

  if !exists('g:MRU_File')
    if has('unix') || has('macunix')
      let g:MRU_File = $VIM . '/_vim_mru_files'
      if exists('$HOME')
        let g:MRU_File = $HOME . '/.vim_mru_files'
      endif
    else
      let g:MRU_File = $VIM . '\_vim_mru_files'
      if has('win32')
        " MS-Windows
        if exists('$USERPROFILE')
          let g:MRU_File = $USERPROFILE . '\_vim_mru_files'
        endif
      endif
    endif
  endif

  " }}}3
  " Mru Dir {{{3
  if !exists('g:MRU_Exclude_Directories')
    let g:MRU_Exclude_Directories = '.*tmp.*|.*temp.*|.*Tmp.*|.*Temp.*'
  endif

  if !exists('g:MRU_Include_Directories')
    let g:MRU_Include_Directories = ''
  endif

  if !exists('g:MRU_Directory')
    if has('unix') || has('macunix')
      let g:MRU_Directory = $VIM . '/_vim_mru_dires'
      if exists('$HOME')
        let g:MRU_Directory = $HOME . '/.vim_mru_dires'
      endif
    else
      let g:MRU_Directory = $VIM . '\_vim_mru_dires'
      if has('win32')
        " MS-Windows
        if exists('$USERPROFILE')
          let g:MRU_Directory = $USERPROFILE . '\_vim_mru_dires'
        endif
      endif
    endif
  endif

  if !exists('g:MRU_Directory_Head_ftype')
    let g:MRU_Directory_Head_ftype = 0
  endif
  " }}}3
  " Mru GotoFile {{{3
  if !exists('g:MRU_GotoFile')
    if has('unix') || has('macunix')
      let g:MRU_GotoFile = $VIM . '/.vim_mru_goto'
      if exists('$HOME')
        let g:MRU_GotoFile = $HOME . '/.vim_mru_goto'
      endif
    else
      let g:MRU_GotoFile = $VIM . '\_vim_mru_goto'
      if has('win32')
        " MS-Windows
        if exists('$USERPROFILE')
          let g:MRU_GotoFile = $USERPROFILE . '\_vim_mru_goto'
        endif
      endif
    endif
  endif
  " }}}3
  " Mru Eval {{{3
  if !exists('g:MRU_Eval')
    if has('unix') || has('macunix')
      let g:MRU_Eval = $VIM . '/.vim_mru_eval'
      if exists('$HOME')
        let g:MRU_Eval = $HOME . '/.vim_mru_eval'
      endif
    else
      let g:MRU_Eval = $VIM . '\_vim_mru_eval'
      if has('win32')
        " MS-Windows
        if exists('$USERPROFILE')
          let g:MMRU_Eval = $USERPROFILE . '\_vim_mru_eval'
        endif
      endif
    endif
  endif
  " }}}3
  " Mru Mark {{{3
  if !exists('g:MRU_Mark_DefaultViewList')
    let g:MRU_Mark_DefaultViewList =
          \ 'abcdefghjklmnopqrstuvwxyz'
          \ . 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  endif

  if !exists('s:MRU_Mark_ViewList')
    let s:MRU_Mark_ViewList = g:MRU_Mark_DefaultViewList
  endif

  if !exists('g:MRU_Use_Mark_CommentLine')
    let g:MRU_Use_Mark_CommentLine = 0
  endif
  " }}}3
  " Mru NetrwBookmark {{{3
  if !exists('g:MRU_FName_netrwbook')
    let g:MRU_FName_netrwbook = '.netrwbook'
  endif
  
  if !exists('g:MRU_NetrwBookmark')
    let g:MRU_NetrwBookmark = s:MRU_Find_NetrwFile(g:MRU_FName_netrwbook)
  endif
  " }}}3
  " Mru NetrwHistory {{{3
  if !exists('g:MRU_FName_netrwhist')
    let g:MRU_FName_netrwhist = '.netrwhist'
  endif
  
  if !exists('g:MRU_NetrwHistory')
    let g:MRU_NetrwHistory = s:MRU_Find_NetrwFile(g:MRU_FName_netrwhist)
  endif
  " }}}3
  " Mru Locate {{{3
  if !exists('g:MRU_Locate_NotInclude')
    " if you g:MRU_Locate_NotInclude disable is empty.
    let g:MRU_Locate_NotInclude = ['temp', '~$']
  endif

  if !exists('g:MRU_Locate_Cmd')
    if has('unix') || has('macunix')
      let g:MRU_Locate_Cmd = 'locate'
    elseif has('win32')
      let g:MRU_Locate_Cmd = 'locate.exe'
    else
      let g:MRU_Locate_Cmd = ''
    endif
  endif
  " }}}3
  " Mru Viminfo {{{3
  if !exists('g:MRU_Viminfo')
    let g:MRU_Viminfo = g:MRU_Find_Viminfo()
  endif
  " }}}3
  " Initialize Value {{{3
  let s:MRU_Config = {}
  let s:MRU_Config['File'] = {
        \ 'bufname'    : '__MRU_File__',
        \ 'load'       : function('s:MRU_LoadList_File'),
        \ 'window'     : function('s:MRU_Open_Window_File'),
        \ 'complete'   : function('s:MRU_Complete'),
        \ 'prepare'    : function('s:MRU_Prepare_File'),
        \ 'statusline' : ['search'],
        \ 'pack'       : 'path',
        \ }
  let s:MRU_Config['Dir'] = {
        \ 'bufname'    : '__MRU_Dir__',
        \ 'load'       : function('s:MRU_LoadList_Dir'),
        \ 'window'     : function('s:MRU_Open_Window_Dir'),
        \ 'complete'   : function('s:MRU_Complete'),
        \ 'prepare'    : function('s:MRU_Prepare_Dir'),
        \ 'statusline' : ['search'],
        \ 'pack'       : 'pathdir',
        \ }
  let s:MRU_Config['Buffer'] = {
        \ 'bufname'    : '__MRU_Buffer__',
        \ 'load'       : function('s:MRU_LoadList_Buffer'),
        \ 'window'     : function('s:MRU_Open_Window_Buffer'),
        \ 'statusline' : ['search'],
        \ 'pack'       : 'plain',
        \ }
  let s:MRU_Config['Mark'] = {
        \ 'bufname'    : '__MRU_Mark__',
        \ 'load'       : function('s:MRU_LoadList_Mark'),
        \ 'window'     : function('s:MRU_Open_Window_Mark'),
        \ 'statusline' : ['search'],
        \ 'pack'       : 'plain',
        \ }
  let s:MRU_Config['NetrwBookmark'] = {
        \ 'bufname'    : '__Netrw_Bookmark__',
        \ 'load'       : function('s:MRU_LoadList_Netrw_Bookmark'),
        \ 'window'     : function('s:MRU_Open_Window_Netrw_Bookmark'),
        \ 'complete'   : function('s:MRU_Complete'),
        \ 'prepare'    : function('s:MRU_Prepare_Netrw_Bookmark'),
        \ 'statusline' : ['search'],
        \ 'pack'       : 'pathdir',
        \ }
  let s:MRU_Config['NetrwHistory'] = {
        \ 'bufname'    : '__Netrw_History__',
        \ 'load'       : function('s:MRU_LoadList_Netrw_History'),
        \ 'window'     : function('s:MRU_Open_Window_Netrw_History'),
        \ 'complete'   : function('s:MRU_Complete'),
        \ 'prepare'    : function('s:MRU_Prepare_Netrw_History'),
        \ 'statusline' : ['search'],
        \ 'pack'       : 'pathdir',
        \ }
  let s:MRU_Config['GotoFile'] = {
        \ 'bufname'    : '__Goto_File__',
        \ 'load'       : function('s:MRU_LoadList_Goto_File'),
        \ 'window'     : function('s:MRU_Open_Window_Goto_File'),
        \ 'complete'   : function('s:MRU_Complete'),
        \ 'prepare'    : function('s:MRU_Prepare_Goto_File'),
        \ 'statusline' : ['search'],
        \ 'pack'       : 'path'
        \ }
  let s:MRU_Config['Eval'] = {
        \ 'bufname'    : '__Eval__',
        \ 'load'       : function('s:MRU_LoadList_Eval'),
        \ 'window'     : function('s:MRU_Open_Window_Eval'),
        \ 'complete'   : function('s:MRU_Complete'),
        \ 'prepare'    : function('s:MRU_Prepare_Eval'),
        \ 'statusline' : ['search'],
        \ 'pack'       : 'plain',
        \ }
  let s:MRU_Config['Seek'] = {
        \ 'bufname'    : '__MRU_Seek__',
        \ 'load'       : function('s:MRU_LoadList_Seek'),
        \ 'window'     : function('s:MRU_Open_Window_Seek'),
        \ 'prepare'    : function('s:MRU_Prepare_Seek'),
        \ 'statusline' : ['input', 'search'],
        \ 'pack'       : 'path'
        \ }
  let s:MRU_Config['Locate'] = {
        \ 'bufname'    : '__MRU_Locate__',
        \ 'load'       : function('s:MRU_LoadList_Locate'),
        \ 'window'     : function('s:MRU_Open_Window_Locate'),
        \ 'prepare'    : function('s:MRU_Prepare_Locate'),
        \ 'statusline' : ['input', 'search'],
        \ 'pack'       : 'path',
        \ }

  " Netrw like.
  let s:MRU_Config['NetrwFiler'] = {
        \ 'bufname'    : '__MRU_Netrw_Filer__',
        \ 'load'       : function('s:MRU_LoadList_Netrw_Filer'),
        \ 'window'     : function('s:MRU_Open_Window_Netrw_Filer'),
        \ 'prepare'    : function('s:MRU_Prepare_Netrw_Filer'),
        \ 'statusline' : ['cwd', 'search'],
        \ 'pack'       : 'netrwfiler',
        \ }
  let s:MRU_Config['Mirror'] = {
        \ 'bufname'    : '__MRU_Mirror__',
        \ 'load'       : function('s:MRU_LoadList_Mirror'),
        \ 'window'     : function('s:MRU_Open_Window_Mirror'),
        \ 'prepare'     : function('s:MRU_Prepare_Mirror'),
        \ 'statusline' : ['search'],
        \ 'pack'       : 'mirror',
        \ }
  for l:key in keys(s:MRU_Config)
    let s:MRU_Config[l:key].data = [] " list
  endfor

  " MRU_Base
  let s:MRU_Base_CompleteList = []
  let s:MRU_ExecCmd = ''

  " History
  let s:MRU_SearchHistory = []
  let s:MRU_InputHistory = []

  let s:MRU_DisplayPack = {}
  " default settings.
  for l:key in keys(s:MRU_Config)
    if has_key(s:MRU_Config[l:key], 'pack')
      let l:packname = s:MRU_Config[l:key].pack
    else
      let l:packname = 'plain'
    endif

    if !has_key(s:MRU_DisplayPack, l:packname)
      let s:MRU_DisplayPack[l:packname] = {}
      let s:MRU_DisplayPack[l:packname].pack = function('s:MRU_Display_Plain_Pack')
      let s:MRU_DisplayPack[l:packname].unpack = function('s:MRU_Display_Plain_UnPack')
    endif
  endfor

  " Override
  let s:MRU_DisplayPack['path'] = {
    \ 'pack'       : function('s:MRU_Display_Path_Pack'),
    \ 'unpack'     : function('s:MRU_Display_Path_UnPack'),
    \ }
  let s:MRU_DisplayPack['pathdir'] = {
    \ 'pack'       : function('s:MRU_Display_PathDir_Pack'),
    \ 'unpack'     : function('s:MRU_Display_PathDir_UnPack'),
    \ }
  let s:MRU_DisplayPack['mirror'] = {
    \ 'pack'       : function('s:MRU_Display_Mirror_Pack'),
    \ 'unpack'     : function('s:MRU_Display_Mirror_UnPack'),
    \ }
  " }}}3
endfunction "}}}2
function! s:MRU_Env_SetLocal(...) dict "{{{2
  " Mark the buffer as scratch
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal nowrap
  setlocal nobuflisted
  " Use fixed height for the MRU window
  setlocal winfixheight

  if g:MRU_Use_CursorLine
    setlocal cursorline
  else
    setlocal nocursorline
  endif
  setlocal nolist

  " header
  let l:statusline = 'setlocal statusline=%<%f\ '
  " body
  let l:statusline .= '%{g:MRU_StatusLine_CurrentWorkingDirectory(' . count(self.statusline, 'cwd', 0) . ')}'
  let l:statusline .= '%{g:MRU_StatusLine_InputHistory(' . count(self.statusline, 'input', 0) . ')}'
  let l:statusline .= '%{g:MRU_StatusLine_SearchHistory(' . count(self.statusline, 'search', 0) . ')}'
  let l:statusline .= '%{g:MRU_StatusLine_MultipleSelect()}'
  " footer
  let l:statusline .= '%y%=R%l,C%v%V%6P\ \<\ %L'

  execute l:statusline
endfunction "}}}2
function! s:MRU_Env_Keymap() "{{{2
  " TODO:add args dict. check multiple open.
  nnoremap <buffer> <silent> u :call <SID>MRU_Msg_EchoAndRedraw('Reopen.')<CR>:call <SID>MRU_ReOpen_Window()<CR>
  nnoremap <buffer> <silent> q :call <SID>MRU_Close_Window()<CR>
  nnoremap <buffer> <silent> <Esc> :call <SID>MRU_Close_Window()<CR>
  nnoremap <buffer> <silent> s :call <SID>MRU_SearchStrings()<CR>
  nnoremap <buffer> <silent> S :call <SID>MRU_SearchNotStrings()<CR>
  nnoremap <buffer> <silent> n :silent! exec "normal! n"<CR>:noh<CR>
  nnoremap <buffer> <silent> N :silent! exec "normal! N"<CR>:noh<CR>
  nnoremap <buffer> <silent> r :call <SID>MRU_Msg_EchoAndRedraw('Sort.')<CR>:call <SID>MRU_Init_SingPlace()<CR>:setlocal modifiable<CR>:sort<CR>:setlocal nomodifiable<CR>
  nnoremap <buffer> <silent> R :call <SID>MRU_Msg_EchoAndRedraw('Reverse-Sort.')<CR>:call <SID>MRU_Init_SingPlace()<CR>:setlocal modifiable<CR>:sort!<CR>:setlocal nomodifiable<CR>
  nnoremap <buffer> <silent> H :call <SID>MRU_Msg_EchoAndRedraw('Resize to full.')<CR>:resize<CR>
  nnoremap <buffer> <silent> h :call <SID>MRU_Msg_EchoAndRedraw('Resize to intial size.')<CR>:execute 'resize ' . w:MRU_Window_HeightSize<CR>
  nnoremap <buffer> <silent> <F2> :call <SID>MRU_Close_Window()<CR>:execute 'edit ' . g:MRU_GotoFile<CR>
  nnoremap <buffer> <silent> <F3> :call <SID>MRU_Close_Window()<CR>:execute 'edit ' . g:MRU_Eval<CR>
  if has('signs')
    nnoremap <buffer> <silent> a :call <SID>MRU_Toggle_Sign()<CR>
  endif
endfunction "}}}2
function! s:MRU_Env_AutoCmd() "{{{2
  " Autocommands to detect the most recently used files
  autocmd BufRead * call s:MRU_AutoCmd_DetectMRU(expand('<abuf>'))
  autocmd BufNewFile * call s:MRU_AutoCmd_DetectMRU(expand('<abuf>'))
  autocmd BufWritePost * call s:MRU_AutoCmd_DetectMRU(expand('<abuf>'))
  autocmd TabLeave * call s:MRU_AutoCmd_HideMRU()

  " The ':vimgrep' command adds all the files searched to the buffer list.
  " This also modifies the MRU list, even though the user didn't edit the
  " files. Use the following autocmds to prevent this.
  autocmd QuickFixCmdPre  *vimgrep* let s:mru_list_locked = 1
  autocmd QuickFixCmdPost *vimgrep* let s:mru_list_locked = 0
  autocmd QuickFixCmdPre  *grep*    let s:mru_list_locked = 1
  autocmd QuickFixCmdPost *grep*    let s:mru_list_locked = 0
endfunction "}}}2
function! s:MRU_Env_Highlight() "{{{2
  " Highlight Settings.
  hi MRUSearchHistory1 ctermfg=1 guifg=Red
  hi MRUSearchHistory2 ctermfg=2 guifg=DarkGreen
  hi MRUSearchHistory3 ctermfg=3 guifg=DarkYellow
  hi MRUSearchHistory4 ctermfg=4 guifg=Blue
  hi MRUSearchHistory5 ctermfg=5 guifg=Magenta
  hi MRUSearchHistory6 ctermfg=6 guifg=Cyan
  hi MRUSearchHistory7 ctermfg=7 guifg=White
  hi MRUSearchHistory8 ctermfg=8 guifg=DarkGray
  hi MRUSearchHistory9 ctermfg=9 guifg=LightRed
endfunction "}}}2
function! s:MRU_Env_RegistCmd() "{{{2
  command! -nargs=+ -complete=customlist,s:MRU_Complete_Base Mru
        \ call s:MRU_Cmd_Base(<f-args>) |
        \ let b:saved_mru_search=@/

  command! MruLinkRotCheck
        \ call s:MRU_Check_FileReadable('command')

  command! MruStatus
        \ call s:MRU_Msg_Status()

  command! MruHelp
        \ call s:MRU_Msg_Help()

endfunction "}}}2
function! s:MRU_Env_Display(pattern) dict "{{{2
  call s:MRU_Init_SingPlace()
  setlocal modifiable

  if has_key(self, 'pack')
    if has_key(s:MRU_DisplayPack, self.pack)
      let self.data = call(s:MRU_DisplayPack[self.pack].pack, [], self)
    else
      call s:MRU_Msg_Error(self.pack . ' is not registered.(s:MRU_DisplayPack)')
    endif
  endif

  if a:pattern == ''
    " No search pattern specified. Display the complete list
    silent! 0put = self.data
  else
    " Display only the entries matching the specified pattern
    " First try using it as a literal pattern
    let m = filter(copy(self.data), 'stridx(v:val, a:pattern) != -1')
    if len(m) == 0
      " No match. Try using it as a regular expression
      let m = filter(copy(self.data), 'v:val =~# a:pattern')
    endif
    silent! 0put =m
  endif

  " saved pattern.
  let s:saved_mru_pattern = a:pattern

  " last line is blank line.
  normal! G
  if strlen(getline('.')) < 1
    silent! delete _
  endif

  " Move the cursor to the beginning of the file
  normal! gg

  setlocal nomodifiable
endfunction "}}}2
function! s:MRU_Complete(ArgLead, CmdLine, CursorPos, key) "{{{2
    call s:MRU_Config[a:key].load()
    if a:ArgLead == ''
        " Return the complete list of MRU files
        return s:MRU_Config[a:key].data
    else
        " Return only the files matching the specified pattern
        return filter(copy(s:MRU_Config[a:key].data), 'v:val =~? a:ArgLead')
    endif
endfunction "}}}2
" }}}1
" Func:Msg {{{1
function! s:MRU_Msg_Warning(msg) " {{{2
    echohl WarningMsg
    echo a:msg
    echohl None
endfunction " }}}2
function! s:MRU_Msg_Success(msg) " {{{2
    echohl MoreMsg
    echo a:msg
    echohl None
endfunction " }}}2
function! s:MRU_Msg_Error(msg) " {{{2
    echohl ErrorMsg
    echo a:msg
    echohl None
endfunction " }}}2
function! s:MRU_Msg_EchoAndRedraw(string) "{{{2
  if g:MRU_Use_Keymap_Execute_Msg
    redraw | echo a:string
  endif
endfunction " }}}2
function! s:MRU_Msg_Help() " {{{2
  echo '<MRU HELP>'
  echo printf("%6s + %s", '------', '------------')
  echo printf("%6s | %s", 'Keymap', 'Note')
  echo printf("%6s + %s", '------', '------------')
  echo printf("%6s | %s", 'u', 'MRU Window ReOpen.')
  echo printf("%6s | %s", 'q', 'MRU Window Close.')
  echo printf("%6s | %s", '<ESC>', 'MRU Window Close.')
  echo printf("%6s | %s", 's', 'Naroowing Down.')
  echo printf("%6s | %s", 'S', 'Naroowing Down(Exclude).')
  echo printf("%6s | %s", 'r', 'Sort.')
  echo printf("%6s | %s", 'R', 'Reverse-Sort.')
  echo printf("%6s | %s", 'H', 'Set Maximum Height.')
  echo printf("%6s | %s", 'h', 'Set Standard Height.')
  echo printf("%6s | %s", '<F2>', 'GotoFile Open.(' . g:MRU_GotoFile . ')')
  echo printf("%6s | %s", '<F3>', 'Eval-File Open.(' . g:MRU_Eval . ')')
endfunction " }}}2
function! s:MRU_Msg_Status() " {{{2
  echo '<MRU STATUS>'
  echo printf("%2s + %-20s + %s" , '--'                              , '--------------------' , '--------------------')
  echo printf("%2s | %-20s | %s" , 'FR'                              , 'VALUE'                , 'PATH')
  echo printf("%2s + %-20s + %s" , '--'                              , '--------------------' , '--------------------')
  echo printf("%2d | %-20s | %s" , filereadable(g:MRU_File)          , 'g:MRU_File'           , g:MRU_File)
  echo printf("%2d | %-20s | %s" , filereadable(g:MRU_Directory)     , 'g:MRU_Directory'      , g:MRU_Directory)
  echo printf("%2d | %-20s | %s" , filereadable(g:MRU_GotoFile)      , 'g:MRU_GotoFile'       , g:MRU_GotoFile)
  echo printf("%2d | %-20s | %s" , filereadable(g:MRU_Eval)          , 'g:MRU_Eval'           , g:MRU_Eval)
  echo printf("%2d | %-20s | %s" , filereadable(g:MRU_NetrwBookmark) , 'g:MRU_NetrwBookmark'  , g:MRU_NetrwBookmark)
  echo printf("%2d | %-20s | %s" , filereadable(g:MRU_NetrwHistory)  , 'g:MRU_NetrwHistory'   , g:MRU_NetrwHistory)
  echo printf("%2d | %-20s | %s" , filereadable(g:MRU_Viminfo)       , 'g:MRU_Viminfo'        , g:MRU_Viminfo)
  echo printf("%2s + %-20s + %s" , '--'                              , '--------------------' , '--------------------')
  echo 'FR is filereable value. 1 = read OK. 0 = read NG.'
endfunction " }}}2
" }}}1
" Func:Window{{{1
" s:MRU_Close_Window {{{2
function! s:MRU_Close_Window()
    let @/ = b:saved_mru_search
    nohlsearch
    if tabpagenr("$") == 1 && winnr("$") == 1
      buffer #
    else
      close
      wincmd p
    endif
  endfunction
  " }}}2
  " s:MRU_ReOpen_Window {{{2
function! s:MRU_ReOpen_Window()
  for l:key in keys(s:MRU_Config)
    if s:MRU_Config[l:key].bufname == bufname('%')
      call s:MRU_Config[l:key].window(s:saved_mru_pattern)
    endif
  endfor
endfunction
" }}}2
" s:MRU_AlreadyOpen_Window {{{2
function! s:MRU_AlreadyOpen_Window(bname)
  " this windows exists MRU buffer to delete.
  for l:key in keys(s:MRU_Config)
    let l:winnum = bufwinnr(s:MRU_Config[l:key].bufname)
    if l:winnum != -1
      exe 'bwipeout! ' . s:MRU_Config[l:key].bufname
    endif
  endfor

  " save.
  if exists('b:saved_mru_search')
    let l:saved_mru_search_save = b:saved_mru_search
  else
    let l:saved_mru_search_save = ''
  endif

  " open window.
  exe 'silent! botright ' g:MRU_Window_Height . 'split ' . a:bname

  " restore.
  let b:saved_mru_search = l:saved_mru_search_save

  " remember height size for 'Mru NetrwFiler'.
  let w:MRU_Window_HeightSize = winheight(0)

  " reset search hisotry.
  let s:MRU_SearchHistory = []
  call s:MRU_HiReset_SearchHistory()
endfunction

" s:MRU_Forcus_Window {{{2
" @return: 1:Find in window. 0:Not find in window.
function! s:MRU_Forcus_Window()
  for l:key in keys(s:MRU_Config)
    let l:find_winnr = bufwinnr(s:MRU_Config[l:key].bufname)
    if l:find_winnr != -1
      if winnr() != l:find_winnr
        exe l:find_winnr . 'wincmd w'
      endif
      return 1
    endif
  endfor

  return 0
endfunction
" }}}2
" }}}1
" Func:FileUtil {{{1
function! s:MRU_SaveList_File() " {{{2
    let l:data = []
    call add(l:data, '# Most recently edited files in Vim.')
    call extend(l:data, s:MRU_Config['File'].data)
    call writefile(l:data, g:MRU_File)
endfunction
" }}}2
function! s:MRU_SaveList_Directory() " {{{2
    let l:data = []
    call add(l:data, '# Most recently Directories in Vim.')
    call extend(l:data, s:MRU_Config['Dir'].data)
    call writefile(l:data, g:MRU_Directory)
endfunction
" }}}2
function! s:MRU_SaveList_Goto_File() "{{{2
    let l:data = []
    call add(l:data, '# Your favorite file and dir in Vim.')
    call extend(l:data, s:MRU_Config['GotoFile'].data)
    call writefile(l:data, g:MRU_GotoFile)
endfunction
" }}}2
function! s:MRU_SaveList_Eval() " {{{2
    let l:data = []
    call add(l:data, '# Your favorite Command in Vim.')
    call extend(l:data, s:MRU_Config['Eval'].data)
    call writefile(l:data, g:MRU_Eval)
endfunction
" }}}2
function! s:MRU_Add_File(acmd_bufnr) " {{{2
"   acmd_bufnr - Buffer number of the file to add

    if s:mru_list_locked
        " MRU list is currently locked
        return
    endif

    " Get the full path to the filename
    let l:fname = fnamemodify(bufname(a:acmd_bufnr + 0), ':p')
    if l:fname == ''
        return
    endif

    " Skip temporary buffers with buftype set. The buftype is set for buffers
    " used by plugins.
    if &buftype != ''
        return
    endif

    if g:MRU_Include_Files != ''
        " If MRU_Include_Files is set, include only files matching the
        " specified pattern
        if l:fname !~# g:MRU_Include_Files
            return
        endif
    endif

    if g:MRU_Exclude_Files != ''
        " Do not add files matching the pattern specified in the
        " MRU_Exclude_Files to the MRU list
        if l:fname =~# g:MRU_Exclude_Files
            return
        endif
    endif

    " If the filename is not already present in the MRU list and is not
    " readable then ignore it
    let idx = index(s:MRU_Config['File'].data, l:fname)
    if idx == -1
        if !filereadable(l:fname)
            " File is not readable and is not in the MRU list
            return
        endif
    endif

    " Load the latest MRU file list
    call s:MRU_Config['File'].load()

    " Remove the new file name from the existing MRU list (if already present)
    call filter(s:MRU_Config['File'].data, 'v:val !=# l:fname')

    " Add the new file list to the beginning of the updated old file list
    call insert(s:MRU_Config['File'].data, l:fname, 0)

    " Trim the list
    if len(s:MRU_Config['File'].data) > g:MRU_Max_Entries
        call remove(s:MRU_Config['File'].data, g:MRU_Max_Entries, -1)
    endif

    " Save the updated MRU list
    call s:MRU_SaveList_File()

    " If the MRU window is open, update the displayed MRU list
    let l:bname = s:MRU_Config['File'].bufname
    let l:winnum = bufwinnr(l:bname)
    if l:winnum != -1
        let l:cur_winnr = winnr()
        call s:MRU_Config['File'].window(s:saved_mru_pattern)
        if winnr() != l:cur_winnr
            exe cur_winnr . 'wincmd w'
        endif
    endif
endfunction
" }}}2
function! s:MRU_Add_Directory(dname) " {{{2
    if s:mru_list_locked
        " MRU list is currently locked
        return
    endif

    " Get the full path to the filename
    "let a:dname = fnamemodify(bufname(l:acmd_bufnr + 0), ':p:h')
    if a:dname == ''
        return
    endif

    " Skip temporary buffers with buftype set. The buftype is set for buffers
    " used by plugins.
    if &buftype != ''
        return
    endif

    if g:MRU_Include_Directories != ''
        " If MRU_Include_Files is set, include only files matching the
        " specified pattern
        if a:dname !~# g:MRU_Include_Directories
            return
        endif
    endif

    if g:MRU_Exclude_Directories != ''
        " Do not add files matching the pattern specified in the
        " MRU_Exclude_Files to the MRU list
        if a:dname =~# g:MRU_Exclude_Directories
            return
        endif
    endif

    " If the filename is not already present in the MRU list and is not
    " readable then ignore it
    let idx = index(s:MRU_Config['Dir'].data, a:dname)
    if idx == -1
        if !isdirectory(a:dname)
            " a:dname Direcotry is Nothing.
            return
        endif
    endif

    " Load the latest MRU file list
    call s:MRU_Config['Dir'].load()

    " Remove the new file name from the existing MRU list (if already present)
    call filter(s:MRU_Config['Dir'].data, 'v:val !=# a:dname')

    " Add the new file list to the beginning of the updated old file list
    call insert(s:MRU_Config['Dir'].data, a:dname, 0)

    " Trim the list
    if len(s:MRU_Config['Dir'].data) > g:MRU_Max_Entries
        call remove(s:MRU_Config['Dir'].data, g:MRU_Max_Entries, -1)
    endif

    " Save the updated MRU list
    call s:MRU_SaveList_Directory()

    " If the MRU window is open, update the displayed MRU list
    let bname = s:MRU_Config['Dir'].bufname
    let winnum = bufwinnr(bname)
    if winnum != -1
        let cur_winnr = winnr()
        call s:MRU_Config['Dir'].window(s:saved_mru_pattern)
        if winnr() != cur_winnr
            exe cur_winnr . 'wincmd w'
        endif
    endif
endfunction
" }}}2
function! g:MRU_Find_Viminfo() " {{{2
  if has('win32')
    if exists('$HOME')
      let l:path = $HOME . '\_viminfo'
      if filereadable(l:path)
        return l:path
      endif
    else
      let l:path = 'c:\_viminfo'
      if filereadable(l:path)
        return l:path
      endif
    endif
  else
    if exists('$HOME')
      let l:path = $HOME . '/.viminfo'
      if filereadable(l:path)
        return l:path
      endif
    else
      let l:path = $VIM . '/.viminfo'
      if filereadable(l:path)
        return l:path
      endif
    endif
  endif

  return 'not_found'
endfunction " }}}2
function! s:MRU_Find_NetrwFile(netrw_fname) " {{{2
  if has('win32')
    let l:sep = '\'
  else
    let l:sep = '/'
  endif

  if exists('g:netrw_home')
    let l:path = g:netrw_home . l:sep . a:netrw_fname
    if filereadable(l:path)
      return l:path
    endif
  endif

  if has('win32')
    if exists('$USERPROFILE')
      let l:path = $USERPROFILE . l:sep . a:netrw_fname
      if filereadable(l:path)
        return l:path
      endif
    endif
  endif

  if exists('$HOME')
    let l:path = $HOME . l:sep . a:netrw_fname
    if filereadable(l:path)
      return l:path
    endif
  endif

  if exists('$HOME' . l:sep . '.vim')
    let l:path = $HOME . l:sep . '.vim' . l:sep . a:netrw_fname
    if filereadable(l:path)
      return l:path
    endif
  endif

  if exists('$VIM')
    let l:path = $VIM . l:sep . a:netrw_fname
    if filereadable(l:path)
      return l:path
    endif
  endif

  if exists('$VIM' . l:sep . 'vimfiles')
    let l:path = $VIM . l:sep . 'vimfiles' . l:sep . a:netrw_fname
    if filereadable(l:path)
      return l:path
    endif
  endif

  if exists('$VIMRUNTIME') 
    let l:path = $VIMRUNTIME . l:sep . a:netrw_fname
    if filereadable(l:path)
      return l:path
    endif
  endif

  return 'not_found'
endfunction
" }}}2
function! s:MRU_Check_FileReadable(cmd) " {{{2
  " File&Directory exist check.
  if filereadable(g:MRU_File)
    let s:MRU_Config['File'].data = readfile(g:MRU_File)
    let l:MRU_files_len= len(s:MRU_Config['File'].data)
    let l:delete_idxfix = 0
    for l:idx in range(0, len(s:MRU_Config['File'].data)-1)
      if glob(s:MRU_Config['File'].data[l:idx - l:delete_idxfix]) == ''
        call remove(s:MRU_Config['File'].data, l:idx - l:delete_idxfix)
        let l:delete_idxfix += 1
      endif
    endfor

    " header文を引いて計算する
    if (l:MRU_files_len - 1) != len(s:MRU_Config['File'].data)
      call s:MRU_SaveList_File()

      if a:cmd != 'startup'
        " If the MRU window is open, update the displayed MRU list
        if s:MRU_Forcus_Window() == 1
          call s:MRU_ReOpen_Window()
          wincmd p
        endif
      endif
      call s:MRU_Msg_Success(g:MRU_File . ' is updated.')
    else
      call s:MRU_Msg_Success(g:MRU_File . ' is not updated.(no link rot)')
    endif
  endif

  if filereadable(g:MRU_Directory)
    let s:MRU_Config['Dir'].data = readfile(g:MRU_Directory)
    let l:MRU_Directories_len = len(s:MRU_Config['Dir'].data)
    let l:delete_idxfix = 0
    for l:idx in range(0, len(s:MRU_Config['Dir'].data)-1)
      if glob(s:MRU_Config['Dir'].data[l:idx - l:delete_idxfix]) == ''
        call remove(s:MRU_Config['Dir'].data, l:idx - l:delete_idxfix)
        let l:delete_idxfix += 1
      endif
    endfor

    " header文を引いて計算する
    if (l:MRU_Directories_len - 1) != len(s:MRU_Config['Dir'].data)
      call s:MRU_SaveList_Directory()

      if a:cmd != 'startup'
        " If the MRU window is open, update the displayed MRU list
        if s:MRU_Forcus_Window() == 1
          call s:MRU_ReOpen_Window()
          wincmd p
        endif
      endif
      call s:MRU_Msg_Success(g:MRU_Directory . ' is updated.')
    else
      call s:MRU_Msg_Success(g:MRU_Directory . ' is not updated.(no link rot)')
    endif
  endif
endfunction
" }}}2
" }}}1
" Func:Search {{{1
" MRU_SearchStrings {{{2
function! s:MRU_SearchStrings()
	let l:key = input("Narrowing Down: ")
	let l:key = fnameescape(l:key)
	let l:key = substitute(l:key, '\.', '\\.', 'g')
    if strlen(l:key) > 0
      let @/='^'.l:key
      call s:MRU_Init_SingPlace()
      setlocal modifiable
      silent! exec ':g!/'.l:key.'/d'
      call cursor('1', '1')
      setlocal nomodifiable
      nohlsearch
      " search history add.
      call add(s:MRU_SearchHistory, l:key)
      call s:MRU_Hi_SearchHistory()
      call s:MRU_Init_SingPlace()
    endif
endfunction
" }}}2
" MRU_SearchNotStrings {{{2
function! s:MRU_SearchNotStrings()
	let l:key = input("Narrowing Down(Exclude): ")
	let l:key = fnameescape(l:key)
	let l:key = substitute(l:key, '\.', '\\.', 'g')
    if strlen(l:key) > 0
      let @/='^'.l:key
      call s:MRU_Init_SingPlace()
      setlocal modifiable
      silent! exec ':g/'.l:key.'/d'
      call cursor('1', '1')
      setlocal nomodifiable
      nohlsearch
      call add(s:MRU_SearchHistory, '!'.l:key)
    endif
endfunction
" }}}2
" }}}1
" Func:AutoCmd{{{1
" s:MRU_AutoCmd_DetectMRU {{{2
function! s:MRU_AutoCmd_DetectMRU(acmd_bufnr)
  call s:MRU_Add_File(a:acmd_bufnr)
  if filereadable(fnamemodify(bufname(a:acmd_bufnr + 0), ':p'))
    call s:MRU_Add_Directory(fnamemodify(bufname(a:acmd_bufnr + 0), ':p:h'))
  endif
endfunction
" }}}2
" s:MRU_AutoCmd_HideMRU {{{2
function! s:MRU_AutoCmd_HideMRU()
  for l:key in keys(s:MRU_Config)
    let l:winnum = bufwinnr(s:MRU_Config[l:key].bufname)
    if l:winnum != -1
      if winnr("$") == 1
        if tabpagenr("$") == 1
          buffer #
        else
          tabclose
        endif
        return
      else
        exe l:winnum . 'wincmd w'
        hide
      endif
    endif
  endfor

  if winnr("$") > 0
     exe 'wincmd p'
  endif
endfunction
" }}}2
" }}}1
" Func:StatusLine {{{1
function! g:MRU_StatusLine_CurrentWorkingDirectory(visible) " {{{2
  if a:visible < 1
    return ""
  endif

  if s:MRU_Config['NetrwFiler'].bufname == bufname('%')
    let l:str = s:MRU_Config['NetrwFiler'].config_currentpath
  else
    let l:str = getcwd()
  endif

  if strlen(l:str) != 0
    return "CWD:[" . l:str . "]" . " "
  else
    return ""
  endif
endfunction " }}}2
function! g:MRU_StatusLine_SearchHistory(visible) " {{{2
  if a:visible < 1
    return ""
  endif

  let l:str = ''

  for l:search in s:MRU_SearchHistory
    if strlen(l:str) != 0
      let l:str .= " | " . l:search
    else
      let l:str .= l:search
    endif
  endfor

  if strlen(l:str) != 0
    return "SRCH:[" . l:str . "]" . " "
  else
    return ""
  endif
endfunction " }}}2
function! g:MRU_StatusLine_InputHistory(visible) " {{{2
  if a:visible < 1
    return ""
  endif

  let l:str = ''

  for l:input in s:MRU_InputHistory
    if strlen(l:str) != 0
      let l:str .= " | " . l:input
    else
      let l:str .= l:input
    endif
  endfor

  if strlen(l:str) != 0
    return "INP:[" . l:str . "]" . " "
  else
    return ""
  endif
endfunction " }}}2
function! g:MRU_StatusLine_MultipleSelect() " {{{2
  let l:num = s:MRU_Get_SignPlaceNum(bufnr("%"))
  if l:num > 0
    return 'MULTI:[ ' . l:num . ' ]'
  else
    return ''
  endif
endfunction " }}}2
" }}}1
" Func:HighLight {{{1
function! s:MRU_Hi_SearchHistory() " {{{2
  let l:i = 1
  for l:keyword in s:MRU_SearchHistory
    if match(l:keyword, '\u') >= 0
      exe 'syntax match MRUSearchHistory' . l:i . ' display "' . l:keyword . '"'
    else
      exe 'syntax match MRUSearchHistory' . l:i . ' display "\c' . l:keyword . '"'
    endif
    let l:i += 1
  endfor
endfunction " }}}2
function! s:MRU_HiReset_SearchHistory() " {{{2
  syntax clear
endfunction " }}}2
" }}}1
" Func:DoCmd{{{1
function! s:MRU_DoCmd(cmd, subcmd) "{{{2
  let g:MRU_EnvVal_DoCmd = {}
  let g:MRU_EnvVal_DoCmd['path'] = {
        \ 'func' : function('s:MRU_DoCmd_Path'),
        \ 'config_close' : 'auto',
        \ }
  let g:MRU_EnvVal_DoCmd['util'] = {
        \ 'func' : function('s:MRU_DoCmd_Util'),
        \ 'config_close' : 'auto',
        \ }
  let g:MRU_EnvVal_DoCmd['buffer'] = {
        \ 'func' : function('s:MRU_DoCmd_Buffer'),
        \ 'config_close' : 'auto',
        \ }
  let g:MRU_EnvVal_DoCmd['mark'] = {
        \ 'func' : function('s:MRU_DoCmd_Mark'),
        \ 'config_close' : 'auto',
        \ }
  let g:MRU_EnvVal_DoCmd['line'] = {
        \ 'func' : function('s:MRU_DoCmd_Line'),
        \ 'config_close' : 'manual',
        \ }
  let g:MRU_EnvVal_DoCmd['filer'] = {
        \ 'func' : function('s:MRU_DoCmd_Netrw'),
        \ 'config_close' : 'manual',
        \ }

  let l:bufnr = bufnr("%")
  let l:unpack_data = ''
  let l:unpack_data_list = []

  for l:key in keys(s:MRU_Config)
    if s:MRU_Config[l:key].bufname == bufname('%')
      let l:pack = s:MRU_Config[l:key].pack

      " multiple select.
      if s:MRU_Get_SignPlaceNum(l:bufnr) > 0
        for l:val in s:MRU_Get_SignPlaceIdList(l:bufnr)
          execute 'sign jump ' . l:val . ' buffer=' . l:bufnr
          call add(l:unpack_data_list, call(s:MRU_DisplayPack[l:pack].unpack, [getline('.')], s:MRU_Config[l:key]))
        endfor
      else
        let l:unpack_data = call(s:MRU_DisplayPack[l:pack].unpack, [getline('.')], s:MRU_Config[l:key])
      endif
    endif
  endfor

  if g:MRU_EnvVal_DoCmd[a:cmd].config_close == 'auto'
    if g:MRU_Auto_Close == 1
      " move buffer
      call s:MRU_Forcus_Window()
      silent! close
    endif
  endif

  if len(l:unpack_data_list) > 0
    for l:val in l:unpack_data_list
      call g:MRU_EnvVal_DoCmd[a:cmd].func(a:subcmd, l:val)
    endfor
  else
    call g:MRU_EnvVal_DoCmd[a:cmd].func(a:subcmd, l:unpack_data)
  endif
endfunction "}}}2
function! s:MRU_DoCmd_Path(subcmd, line) "{{{2
  let g:MRU_OpenCmd = {}
  let g:MRU_OpenCmd['dir'] = {}
  let g:MRU_OpenCmd['dir'].open                    = 'Explore'
  let g:MRU_OpenCmd['dir'].newwin                  = 'leftabove Explore'
  let g:MRU_OpenCmd['dir'].newtab                  = 'Texplore'
  let g:MRU_OpenCmd['dir'].spopen                  = 'Sexplore'
  let g:MRU_OpenCmd['dir'].opendir                 = 'Explore'
  let g:MRU_OpenCmd['dir'].spopendir               = 'Texplore'
  let g:MRU_OpenCmd['dir'].config_split            = 'sp'
  let g:MRU_OpenCmd['dir'].config_autoclose        = 1
  let g:MRU_OpenCmd['dir'].config_usecurrentwindow = 1
  let g:MRU_OpenCmd['file'] = {}
  let g:MRU_OpenCmd['file'].open                    = 'edit'
  let g:MRU_OpenCmd['file'].newwin                  = 'leftabove new'
  let g:MRU_OpenCmd['file'].newtab                  = 'tabnew'
  let g:MRU_OpenCmd['file'].spopen                  = 'split'
  let g:MRU_OpenCmd['file'].view                    = 'view'
  let g:MRU_OpenCmd['file'].spview                  = 'sview'
  let g:MRU_OpenCmd['file'].config_split            = 'sp'
  let g:MRU_OpenCmd['file'].config_autoclose        = 1
  let g:MRU_OpenCmd['file'].config_usecurrentwindow = 1

  " get file-name
  let l:esc_fname = fnameescape(a:line)

  " check file type.
  if a:subcmd == 'opendir' " special subcmd.
    let l:mode = 'dir'
    if isdirectory(l:esc_fname)
      let l:path = l:esc_fname
    else
      let l:path = fnamemodify(l:esc_fname, ':h')
    endif
  elseif isdirectory(l:esc_fname)
    let l:mode = 'dir'
    let l:path = fnamemodify(l:esc_fname, ':h')
  else
    let l:mode = 'file'
    let l:path = fnamemodify(l:esc_fname, ':p')
    if !filereadable(l:path)
      call s:MRU_Msg_Error('File not found.(' . l:path . ')')
      return
    endif
  endif

  " mode check.
  if !has_key(g:MRU_OpenCmd, l:mode)
    call s:MRU_Msg_Error('Invalid mode(' . l:mode . ')')
  endif

  " config settings.
  let l:config = ''
  if has_key(g:MRU_OpenCmd[l:mode], 'config_split')
    if !has_key(g:MRU_OpenCmd[l:mode], l:config . a:subcmd)
      " found.
      let l:config = l:config . g:MRU_OpenCmd[l:mode].config_split
    endif
  else
    call s:MRU_Msg_Error('Invalid subcmd(' . l:config . a:subcmd . ')')
    return
  endif

  " config + subcmd.
  let l:csubcmd = l:config . a:subcmd

  " config + subcmd check.
  if !has_key(g:MRU_OpenCmd[l:mode], l:csubcmd)
    s:MRU_Msg_Error('Invalid subcmd(' . l:csubcmd . ')')
  endif

  execute g:MRU_OpenCmd[l:mode][l:csubcmd] . ' ' . l:path

  if l:mode == 'dir'
    call s:MRU_Add_Directory(l:path)
  endif
endfunction "}}}2
function! s:MRU_DoCmd_Util(subcmd, line) "{{{2
  if a:subcmd == 'cd' " cd is unix cd command like.
    " get file-name
    let l:fname = a:line
    let l:esc_fname = fnameescape(l:fname)

    " get directory path.
    let l:path = fnamemodify(l:esc_fname, ':h')

    call s:MRU_Msg_Success('>cd ' . l:path)
    execute "cd " . l:path
  elseif a:subcmd == 'excmd' " excmd is vimscript execute func.
    wincmd p
    echohl MoreMsg
    let l:input = input('> ', a:line, 'command')
    execute a:line
  else
    call s:MRU_Msg_Warning('Invalid subcmd is ' . a:subcmd)
    return
  endif
endfunction "}}}2
function! s:MRU_DoCmd_Buffer(subcmd, line) "{{{2
  if a:subcmd == 'open'
    " ':buffers' do syntactic analysis.
    let l:mx='\(\d\+\)\ \(.*\)\ "\(.*\)"\ .*\ \(\d\+\)'
    let l = matchstr(a:line, l:mx)
    let l:bufno   = substitute(l, l:mx, '\1', '')
    let l:element = substitute(l, l:mx, '\2', '')
    let l:path    = substitute(l, l:mx, '\3', '')
    let l:lineno  = substitute(l, l:mx, '\4', '')

    let l:bufNbr = l:bufno
    if l:bufNbr == 0
      call s:MRU_Msg_Warning('Cursor-Line is not Buffer-Line.')
      return
    endif

    " If the selected file is already open in one of the windows,
    " jump to it
    let l:winnum = bufwinnr(l:bufNbr)
    if l:winnum != -1
      execute l:winnum . 'wincmd w'
    else
      exe 'buffer ' . l:bufNbr
    endif
  else
    call s:MRU_Msg_Warning('Invalid subcmd is ' . a:subcmd)
    return
  endif
endfunction "}}}2
function! s:MRU_DoCmd_Mark(subcmd, line) "{{{2
  if g:MRU_Use_Mark_CommentLine == 1
    let l:pos = getpos('.')
    " comment line.
    if l:pos[1] == 1
      exec "normal! \<cr>"
      call s:MRU_Msg_Warning('Not mark list.')
      return
    endif
  endif

  let l:bits = split(a:line, '')
  execute "'" . l:bits[0]
endfunction "}}}2
function! s:MRU_DoCmd_Line(subcmd, line) "{{{2
  let l:line_number = a:line

  if a:subcmd == 'open'
    wincmd p
    call setpos(".", [0, l:line_number, 1, "off"])
    normal! zz
  elseif a:subcmd == 'view'
    wincmd p
    call setpos(".", [0, l:line_number, 1, "off"])
    normal! zz
    wincmd p
  else
    call s:MRU_Msg_Warning('Invalid subcmd is ' . a:subcmd)
    return
  endif
endfunction "}}}2
function! s:MRU_DoCmd_Netrw(subcmd, line) "{{{2
  let l:value = a:line

  if a:subcmd == 'parentdir' " 'cd ..' like.
    let l:value = '../'
  endif

  if (a:subcmd == 'open') ||
   \ (a:subcmd == 'parentdir')
    exec 'lcd ' s:MRU_Config['NetrwFiler'].config_currentpath
    if isdirectory(l:value)
      execute 'lcd ' . fnameescape(l:value)
      let s:MRU_Config['NetrwFiler'].config_currentpath = getcwd()

      for l:key in keys(s:MRU_Config)
        if s:MRU_Config[l:key].bufname == bufname('%')
          call s:MRU_Config[l:key].window(s:saved_mru_pattern)
          return
        endif
      endfor
    else
      if g:MRU_Auto_Close == 1
        " move buffer
        call s:MRU_Forcus_Window()
        silent! close
      endif

      execute 'lcd ' . fnameescape(s:MRU_Config['NetrwFiler'].config_currentpath)
      if has('win32')
        call s:MRU_DoCmd_Path('open', s:MRU_Config['NetrwFiler'].config_currentpath . '\' . l:value)
      else
        call s:MRU_DoCmd_Path('open', s:MRU_Config['NetrwFiler'].config_currentpath . '/' . l:value)
      endif
    endif
  elseif a:subcmd == 'createfile'
    call s:MRU_Msg_Error('sorry. can not use ' . a:subcmd)
    return
  elseif a:subcmd == 'delete'
    call s:MRU_Msg_Error('sorry. can not use ' . a:subcmd)
    return
  elseif a:subcmd == 'rename'
    call s:MRU_Msg_Error('sorry. can not use ' . a:subcmd)
    return
  elseif a:subcmd == 'exec'
    call s:MRU_Msg_Error('sorry. can not use ' . a:subcmd)
    return
  else
    call s:MRU_Msg_Warning('Invalid subcmd is ' . a:subcmd)
    return
  endif
endfunction "}}}2
" }}}1
" Func:Keymap {{{1
function! s:MRU_Env_Keymap_OpenFile() "{{{2
  nnoremap <buffer> <silent> o :call <SID>MRU_DoCmd('path', 'newwin')<CR>
  nnoremap <buffer> <silent> t :call <SID>MRU_DoCmd('path', 'newtab')<CR>
  nnoremap <buffer> <silent> v :call <SID>MRU_DoCmd('path', 'view')<CR>
  nnoremap <buffer> <silent> p :call <SID>MRU_DoCmd('path', 'spopen')<CR>
  nnoremap <buffer> <silent> <2-LeftMouse> :call <SID>MRU_DoCmd('path', 'open')<CR>
  nnoremap <buffer> <silent> <CR> :call <SID>MRU_DoCmd('path', 'open')<CR>
  vnoremap <buffer> <silent> <CR> :call <SID>MRU_DoCmd('path', 'open')<CR>
  nnoremap <buffer> <silent> E :call <SID>MRU_DoCmd('path', 'opendir')<CR>
endfunction "}}}2
function! s:MRU_Env_Keymap_OpenDir() "{{{2
  nnoremap <buffer> <silent> c :call <SID>MRU_DoCmd('util', 'cd')<CR>
  nnoremap <buffer> <silent> <CR> :call <SID>MRU_DoCmd('path', 'opendir')<CR>
  nnoremap <buffer> <silent> <2-LeftMouse> :call <SID>MRU_DoCmd('path', 'opendir')<CR>
endfunction "}}}2
function! s:MRU_Env_Keymap_Netrw() "{{{2
  nnoremap <buffer> <silent> c :call <SID>MRU_DoCmd('util', 'cd')<CR>
  nnoremap <buffer> <silent> - :call <SID>MRU_DoCmd('filer', 'parentdir')<CR>
  nnoremap <buffer> <silent> <CR> :call <SID>MRU_DoCmd('filer', 'open')<CR>
  nnoremap <buffer> <silent> <2-LeftMouse> :call <SID>MRU_DoCmd('filer', 'open')<CR>
  nnoremap <buffer> <silent> % :call <SID>MRU_DoCmd('filer', 'createfile')<CR>
  nnoremap <buffer> <silent> D :call <SID>MRU_DoCmd('filer', 'delete')<CR>
  nnoremap <buffer> <silent> R :call <SID>MRU_DoCmd('filer', 'rename')<CR>
  nnoremap <buffer> <silent> x :call <SID>MRU_DoCmd('filer', 'exec')<CR>
endfunction "}}}2
function! s:MRU_Env_Keymap_Line() "{{{2
  nnoremap <buffer> <silent> <CR> :call <SID>MRU_DoCmd('line', 'open')<CR>
  nnoremap <buffer> <silent> <2-LeftMouse> :call <SID>MRU_DoCmd('line', 'open')<CR>
  nnoremap <buffer> <silent> v :call <SID>MRU_DoCmd('line', 'view')<CR>
endfunction "}}}2
function! s:MRU_Env_Keymap_Buffer() "{{{2
  nnoremap <buffer> <silent> <CR> :call <SID>MRU_DoCmd('buffer', 'open')<CR>
  nnoremap <buffer> <silent> <2-LeftMouse> :call <SID>MRU_DoCmd('buffer', 'open')<CR>
endfunction "}}}2
function! s:MRU_Env_Keymap_Mark() "{{{2
  nnoremap <buffer> <silent> <CR> :call <SID>MRU_DoCmd('mark', 'open')<CR>
  nnoremap <buffer> <silent> <2-LeftMouse> :call <SID>MRU_DoCmd('mark', 'open')<CR>
endfunction "}}}2
" }}}1
" Func:Display {{{1
function! s:MRU_Display_Plain_Pack() dict "{{{2
  "DO NOTHING
  return self.data
endfunction "}}}2
function! s:MRU_Display_Plain_UnPack(line) dict "{{{2
  "DO NOTHING
  return a:line
endfunction "}}}2
function! s:MRU_Display_Path_Pack() dict "{{{2
  let l:plist = []
  let l:fname_maxlen = 0
  for idx in range(0, len(self.data)-1)
    if l:fname_maxlen < strlen(substitute(fnamemodify(self.data[idx], ':t'), '.', 'x', 'g'))
      let l:fname_maxlen = strlen(substitute(fnamemodify(self.data[idx], ':t'), '.', 'x', 'g'))
    endif
  endfor

  " round off
  if g:MRU_Max_AddInfoLength < l:fname_maxlen
    let l:fname_maxlen = g:MRU_Max_AddInfoLength
  endif

  let l:idx = 0
  for l:val in self.data
    " init
    let l:fname_maxlenfix = 0
    let l:fname = fnamemodify(l:val, ':t')

    let l:fname_len = strlen(substitute(l:fname, '.', 'x', 'g'))
    if strlen(substitute(l:val, '.', 'x', 'g')) == 0
      continue
    elseif strlen(l:fname) > l:fname_len
      let l:fname_maxlenfix = (strlen(l:fname) - l:fname_len) / 2
    endif
    call add(l:plist, printf('%-' . (l:fname_maxlen + l:fname_maxlenfix) . 's| %s', l:fname, l:val))
    let l:idx += 1
  endfor

  return l:plist
endfunction "}}}2
function! s:MRU_Display_Path_UnPack(line) dict "{{{2
    let l:mx = '\S\+\s*|\s*\(\f\+\)'
    " 正規表現全体にマッチする部分を取り出す
    let l:mstr = matchstr(a:line, l:mx)
    " マッチ結果から各要素を取り出す
    let l:path = substitute(l:mstr, l:mx, '\1', '')

    return l:path
endfunction "}}}2
function! s:MRU_Display_PathDir_Pack() dict "{{{2
  if g:MRU_Directory_Head_ftype == 0
    return self.data
  endif

  let l:glist = self.data
  let l:plist = []

  let l:fname_maxlen = 0
  for idx in range(0, len(l:glist)-1)
    let l:fname = fnamemodify(l:glist[idx], ':t')
    if isdirectory(l:glist[idx])
      let l:fname = '<DIR>'
    endif
    if l:fname_maxlen < strlen(substitute(l:fname, '.', 'x', 'g'))
      let l:fname_maxlen = strlen(substitute(l:fname, '.', 'x', 'g'))
    endif
  endfor

  " round off
  if g:MRU_Max_AddInfoLength < l:fname_maxlen
    let l:fname_maxlen = g:MRU_Max_AddInfoLength
  endif

  let l:idx = 0
  for l:val in l:glist
    " init
    let l:fname_maxlenfix = 0
    let l:fname = fnamemodify(l:val, ':t')

    if isdirectory(l:val)
      let l:fname = '<DIR>'
    endif

    if strlen(substitute(l:val, '.', 'x', 'g')) == 0
      continue
    elseif strlen(l:fname) > strlen(substitute(l:fname, '.', 'x', 'g'))
      let l:fname_maxlenfix = (strlen(l:fname) - strlen(substitute(l:fname, '.', 'x', 'g'))) / 2
    endif
    call add(l:plist, printf('%-' . (l:fname_maxlen + l:fname_maxlenfix) . 's| %s', l:fname, l:val))
    let l:idx += 1
  endfor

  return l:plist
endfunction "}}}2
function! s:MRU_Display_PathDir_UnPack(line) dict "{{{2
  " string back
  return substitute(a:line, ' |.*$','','')
endfunction "}}}2
function! s:MRU_Display_Mirror_Pack() dict "{{{2
  let l:list = []
  let l:endline = printf("%s", len(self.data))
  let l:end = len(self.data)

  let l:i = 0
  while (l:i) < l:end
    " replace line.
    let self.data[l:i] = printf("%" . (strlen(l:endline)) . "d\ |\ %s", (l:i+1) , self.data[l:i])
    let l:i += 1
  endwhile

  return self.data
endfunction "}}}2
function! s:MRU_Display_Mirror_UnPack(line) dict "{{{2
  " string front num
  return str2nr(substitute(a:line, ' |.*$','',''))
endfunction "}}}2
" }}}1
" Func:Signs {{{1
function! s:MRU_Toggle_Sign() "{{{2
  if !has('signs')
    call s:MRU_Msg_Warning('not supported "signs".')
    return
  endif

  let l:cursor = getpos(".")
  let l:bufnr  = bufnr("%")
  if !s:MRU_Check_SignPlace(l:cursor[1], l:bufnr)
    sign define MultipleSelect text=MS texthl=Question
    " TODO:sign id no. duplicate check.
    " TODO:sign id no. do not line number.
    silent! exe 'sign place ' . l:cursor[1] . ' line=' . l:cursor[1] . ' name=MultipleSelect buffer=' . l:bufnr
    "Decho 'on'
  else
    sign unplace
    "Decho 'off'
  endif
endfunction "}}}2
function! s:MRU_Check_SignPlace(line, bufnr) "{{{2
  if !has('signs')
    return 0
  endif

  redir => l:output
  silent! execute 'sign place buffer=' . a:bufnr
  redir END

  let l:output_array = []
  let l:output_array = split(l:output, '\n')
  "Decho l:output_array

  for l:val in l:output_array
    " 正規表現を設定
    let l:mx = '\s*\S\+=\(\d\+\)\s*\S\+=\(\d\+\)\s*\S\+=\(\w\+\)'
    " 正規表現全体にマッチする部分を取り出す
    let l:l = matchstr(l:val, l:mx)
    " マッチ結果から各要素を取り出す
    let l:mx_line = substitute(l:l, l:mx, '\1', '')
    "let l:mx_id   = substitute(l:l, l:mx, '\2', '')
    "let l:mx_name = substitute(l:l, l:mx, '\3', '')

    if l:mx_line == a:line
      return 1
    endif
  endfor

  return 0
endfunction "}}}2
function! s:MRU_Get_SignPlaceNum(bufnr) "{{{2
  if !has('signs')
    return 0
  endif

  redir => l:output
  silent! execute 'sign place buffer=' . a:bufnr
  redir END

  let l:output_array = []
  let l:output_array = split(l:output, '\n')

  let l:cnt = 0
  for l:val in l:output_array
    " 正規表現を設定
    let l:mx = '\s*line=\(\d\+\)\s*id=\(\d\+\)\s*name=\(\w\+\)'
    " 正規表現全体にマッチする部分を取り出す
    let l:l = matchstr(l:val, l:mx)
    " マッチ結果から各要素を取り出す
    let l:mx_line = substitute(l:l, l:mx, '\1', '')
    let l:mx_id   = substitute(l:l, l:mx, '\2', '')
    let l:mx_name = substitute(l:l, l:mx, '\3', '')

    if l:mx_name == 'MultipleSelect'
      let l:cnt += 1
    endif
  endfor

  return l:cnt
endfunction "}}}2
function! s:MRU_Get_SignPlaceIdList(bufnr) "{{{2
  if !has('signs')
    return []
  endif

  redir => l:output
  silent! execute 'sign place buffer=' . a:bufnr
  redir END

  let l:output_array = []
  let l:output_array = split(l:output, '\n')

  let l:result = []
  for l:val in l:output_array
    " 正規表現を設定
    let l:mx = '\s*line=\(\d\+\)\s*id=\(\d\+\)\s*name=\(\w\+\)'
    " 正規表現全体にマッチする部分を取り出す
    let l:l = matchstr(l:val, l:mx)
    " マッチ結果から各要素を取り出す
"    let l:mx_line = substitute(l:l, l:mx, '\1', '')
    let l:mx_id   = substitute(l:l, l:mx, '\2', '')
    let l:mx_name = substitute(l:l, l:mx, '\3', '')

    if l:mx_name == 'MultipleSelect'
      call add(l:result, l:mx_id)
    endif
  endfor

  return l:result
endfunction "}}}2
function! s:MRU_Init_SingPlace() "{{{2
  if !has('signs')
    return []
  endif

  " TODO:backup sign.
  let l:bufnr  = bufnr("%")
  for l:val in s:MRU_Get_SignPlaceIdList(l:bufnr)
    execute 'sign unplace ' . l:val . ' buffer=' . l:bufnr
  endfor
endfunction "}}}2
" }}}1
" CmdFunc:File {{{1
" s:MRU_LoadList_File {{{2
" Loads the latest list of file names from the MRU file
function! s:MRU_LoadList_File() dict
  " If the MRU file is present, then load the list of filenames. Otherwise
  " start with an empty list.
  if !filereadable(g:MRU_File)
    let self.data = []
    return
  endif

  let self.data = readfile(g:MRU_File)

  " Remove comment-line.
  call filter(self.data, 'v:val !~# "^#"')
endfunction
" }}}2
" s:MRU_Open_Window_File {{{2
" Display the Most Recently Used file list in a temporary window.
" If the optional argument is supplied, then it specifies the pattern of files
" to selectively display in the MRU window.
function! s:MRU_Open_Window_File(...) dict

  " Load the latest MRU file list
  call self.load()

  " Check for empty MRU list
  if empty(self.data)
    call s:MRU_Msg_Warning(self.bufname . ' list is empty.')
    return
  endif

  " If the window is already open, jump to it
  call s:MRU_AlreadyOpen_Window(self.bufname)

  " setlocal.
  call call('s:MRU_Env_SetLocal', a:000, self)

  setlocal number

  " Setup the cpoptions properly for the maps to work
  let old_cpoptions = &cpoptions
  set cpoptions&vim

  " keymap.
  call s:MRU_Env_Keymap()
  call s:MRU_Env_Keymap_OpenFile()

  " Restore the previous cpoptions settings
  let &cpoptions = old_cpoptions

  " display.
  call call('s:MRU_Env_Display', [(a:0 > 0 ? a:1 : '')], self)
endfunction
" s:MRU_Prepare_File {{{2
function! s:MRU_Prepare_File(...) dict
  " mru_file check find.
  if !filereadable(g:MRU_File)
    call s:MRU_SaveList_File()
    if filereadable(g:MRU_File)
      call s:MRU_Msg_Success(g:MRU_File . ' is created.')
    else
      call s:MRU_Msg_Error(g:MRU_File . ' is not create.')
      return 0
    endif
  endif

  return 1
endfunction
" }}}2
" }}}1
" CmdFunc:Dir {{{1
" s:MRU_LoadList_Dir {{{2
" Loads the latest list of file names from the MRU file
function! s:MRU_LoadList_Dir() dict
  " If the MRU file is present, then load the list of filenames. Otherwise
  " start with an empty list.
  if !filereadable(g:MRU_Directory)
    let self.data= []
    return
  endif

  let self.data = readfile(g:MRU_Directory)

  " Remove comment-line.
  call filter(self.data, 'v:val !~# "^#"')
endfunction
" }}}2
" s:MRU_Open_Window_Dir {{{2
function! s:MRU_Open_Window_Dir(...) dict
  " Load the latest MRU file list
  call self.load()

  " Check for empty MRU list
  if empty(self.data)
    call s:MRU_Msg_Warning(self.bufname . ' list is empty.')
    return
  endif

  " If the window is already open, jump to it
  call s:MRU_AlreadyOpen_Window(self.bufname)

  " setlocal.
  call call('s:MRU_Env_SetLocal', a:000, self)
  setlocal number

  " Setup the cpoptions properly for the maps to work
  let old_cpoptions = &cpoptions
  set cpoptions&vim

  " keymap.
  call s:MRU_Env_Keymap()
  call s:MRU_Env_Keymap_OpenDir()

  " Restore the previous cpoptions settings
  let &cpoptions = old_cpoptions

  " display.
  call call('s:MRU_Env_Display', [(a:0 > 0 ? a:1 : '')], self)
endfunction
" s:MRU_Prepare_Dir {{{2
function! s:MRU_Prepare_Dir(...) dict
  " mru_dir check find.
  if !filereadable(g:MRU_Directory)
    " mru_dir is create.
    call s:MRU_SaveList_Directory()
    if filereadable(g:MRU_Directory)
      call s:MRU_Msg_Success(g:MRU_Directory . ' is created.')
    else
      call s:MRU_Msg_Error(g:MRU_Directory . ' is not create.')
      return 0
    endif
  endif

  return 1
endfunction
" }}}1
" CmdFunc:Netrw_Bookmark {{{1
" s:MRU_LoadList_Netrw_Bookmark {{{2
function! s:MRU_LoadList_Netrw_Bookmark() dict
  let self.data = []
  if filereadable(g:MRU_NetrwBookmark)
    exe 'keepj so ' . g:MRU_NetrwBookmark
    " If the MRU file is present, then load the list of filenames. Otherwise
    " start with an empty list.
    if exists('g:netrw_bookmarklist')
      for l:item in g:netrw_bookmarklist
        call add(self.data, l:item)
      endfor
    endif
  endif
endfunction
" }}}2
" s:MRU_Open_Window_Netrw_Bookmark {{{2
function! s:MRU_Open_Window_Netrw_Bookmark(...) dict

  " Load the latest MRU file list
  call self.load()

  " Check for empty MRU list
  if empty(self.data)
    call s:MRU_Msg_Warning(self.bufname . ' list is empty.')
    return
  endif

  " If the window is already open, jump to it
  call s:MRU_AlreadyOpen_Window(self.bufname)

  " setlocal.
  call call('s:MRU_Env_SetLocal', a:000, self)

  setlocal number

  " Setup the cpoptions properly for the maps to work
  let old_cpoptions = &cpoptions
  set cpoptions&vim

  " keymap.
  call s:MRU_Env_Keymap()
  call s:MRU_Env_Keymap_OpenDir()

  " Restore the previous cpoptions settings
  let &cpoptions = old_cpoptions

  " display.
  call call('s:MRU_Env_Display', [(a:0 > 0 ? a:1 : '')], self)
endfunction
" }}}2
" s:MRU_Prepare_Netrw_Bookmark {{{2
function! s:MRU_Prepare_Netrw_Bookmark(...) dict
  " g:MRU_NetrwBookmark check find.
  if !filereadable(g:MRU_NetrwBookmark)
    call s:MRU_Msg_Warning('Not found ' . g:MRU_NetrwBookmark . '.')
    call s:MRU_Msg_Warning('Please setting value(g:MRU_NetrwBookmark).')
    return 0
  endif

  return 1
endfunction
" }}}1
" CmdFunc:Netrw_History {{{1
" s:MRU_LoadList_Netrw_History {{{2
function! s:MRU_LoadList_Netrw_History() dict
  let self.data = []
  
  if filereadable(g:MRU_NetrwHistory)
    exe 'keepj so ' . g:MRU_NetrwHistory
    if exists('g:netrw_dirhist_cnt')
      " If the MRU file is present, then load the list of filenames. Otherwise
      " start with an empty list.
      if g:netrw_dirhist_cnt > 0
        let l:Hist_Cnt=1
        while l:Hist_Cnt <= g:netrw_dirhist_cnt
          if exists('g:netrw_dirhist_' . l:Hist_Cnt)
            execute 'call add(self.data, g:netrw_dirhist_' . l:Hist_Cnt . ')'
          else
            MRU_Msg_Warning('undefined value: g:netrw_dirhist_' . l:Hist_Cnt) 
          endif
          let l:Hist_Cnt += 1
        endwhile
      endif
    endif
  endif
endfunction
" }}}2
" s:MRU_Open_Window_Netrw_History {{{2
function! s:MRU_Open_Window_Netrw_History(...) dict

  " Load the latest MRU file list
  call self.load()

  " Check for empty MRU list
  if empty(self.data)
    call s:MRU_Msg_Warning(self.bufname . ' list is empty.')
    return
  endif

  " If the window is already open, jump to it
  call s:MRU_AlreadyOpen_Window(self.bufname)

  " setlocal.
  call call('s:MRU_Env_SetLocal', a:000, self)
  setlocal number

  " Setup the cpoptions properly for the maps to work
  let old_cpoptions = &cpoptions
  set cpoptions&vim

  " keymap
  call s:MRU_Env_Keymap()
  call s:MRU_Env_Keymap_OpenDir()

  " Restore the previous cpoptions settings
  let &cpoptions = old_cpoptions

  " display.
  call call('s:MRU_Env_Display', [(a:0 > 0 ? a:1 : '')], self)
endfunction
" }}}2
" s:MRU_Prepare_Netrw_History {{{2
function! s:MRU_Prepare_Netrw_History(...) dict
  " g:MRU_NetrwHistory check find.
  if !filereadable(g:MRU_NetrwHistory)
    call s:MRU_Msg_Warning('Not found ' . g:MRU_NetrwHistory . '.')
    call s:MRU_Msg_Warning('Please setting value(g:MRU_NetrwHistory).')
    return 0
  endif

  return 1
endfunction
" }}}1
" CmdFunc:Buffer {{{1
" s:MRU_LoadList_Buffer {{{2
function! s:MRU_LoadList_Buffer() dict
  let self.data = []
  " If the MRU file is present, then load the list of filenames. Otherwise
  redir => l:output
  silent! buffers
  redir END

  let self.data = split(l:output, '\n')
endfunction
" }}}2
" s:MRU_Open_Window_Buffer {{{2
function! s:MRU_Open_Window_Buffer(...) dict

  " load.
  call self.load()

  " Check for empty MRU list
  if empty(self.data)
    call s:MRU_Msg_Warning(self.bufname . ' list is empty.')
    return
  endif

  " If the window is already open, jump to it
  call s:MRU_AlreadyOpen_Window(self.bufname)

  " setlocal.
  call call('s:MRU_Env_SetLocal', a:000, self)

  " Setup the cpoptions properly for the maps to work
  let old_cpoptions = &cpoptions

  set cpoptions&vim

  " keymap.
  call s:MRU_Env_Keymap()
  call s:MRU_Env_Keymap_Buffer()

  " Restore the previous cpoptions settings
  let &cpoptions = old_cpoptions

  " display.
  call call('s:MRU_Env_Display', [(a:0 > 0 ? a:1 : '')], self)
endfunction
" }}}2
" }}}1
" CmdFunc:Mark {{{1
" s:MRU_LoadList_Mark {{{2
function! s:MRU_LoadList_Mark() dict
  let self.data = []
  " If the MRU file is present, then load the list of filenames. Otherwise
  redir => l:output
  silent! marks
  redir END

  let l:marklist = split(l:output, '\n')

  if g:MRU_Use_Mark_CommentLine
    " commnet line add.
    call add(self.data, l:marklist[0])
  endif

  " comment line delete.
  call remove(l:marklist, 0)

  for l:val in l:marklist
    let l:bits = split(l:val, '')
    " mark length only 1
    if strlen(l:bits[0]) != 1
      continue
    endif

    if stridx(s:MRU_Mark_ViewList, l:bits[0]) >= 0
      call add(self.data, l:val)
    endif
  endfor
endfunction
" }}}2
" s:MRU_Open_Window_Mark {{{2
function! s:MRU_Open_Window_Mark(...) dict

  " load.
  call self.load()

  " Check for empty MRU list
  if empty(self.data)
    call s:MRU_Msg_Warning(self.bufname . ' list is empty.')
    return
  endif

  " If the window is already open, jump to it
  call s:MRU_AlreadyOpen_Window(self.bufname)

  " setlocal.
  call call('s:MRU_Env_SetLocal', a:000, self)

  " Setup the cpoptions properly for the maps to work
  let old_cpoptions = &cpoptions

  set cpoptions&vim

  " keymap.
  call s:MRU_Env_Keymap()
  call s:MRU_Env_Keymap_Mark()

  " Restore the previous cpoptions settings
  let &cpoptions = old_cpoptions

  " display.
  call call('s:MRU_Env_Display', [(a:0 > 0 ? a:1 : '')], self)
endfunction
" }}}2
" }}}1
" CmdFunc:Goto_File {{{1
function! s:MRU_LoadList_Goto_File() dict "{{{2
  " start with an empty list.
  if filereadable(g:MRU_GotoFile)
    let self.data= readfile(g:MRU_GotoFile)
    if self.data[0] =~# '^#'
      " Remove the comment line
      call remove(self.data, 0)
    endif
  else
    let self.data = []
  endif
endfunction
" }}}2
function! s:MRU_Open_Window_Goto_File(...) dict "{{{2
  " load.
  call self.load()

  " Check for empty MRU list
  if empty(self.data)
    call s:MRU_Msg_Warning(self.bufname . ' list is empty.')
    return
  endif

  " If the window is already open, jump to it
  call s:MRU_AlreadyOpen_Window(self.bufname)

  " setlocal.
  call call('s:MRU_Env_SetLocal', a:000, self)

  setlocal number

  " Setup the cpoptions properly for the maps to work
  let old_cpoptions = &cpoptions

  set cpoptions&vim

  " keymap.
  call s:MRU_Env_Keymap()
  call s:MRU_Env_Keymap_OpenFile()
 
  " Restore the previous cpoptions settings
  let &cpoptions = old_cpoptions

  " display.
  call call('s:MRU_Env_Display', [(a:0 > 0 ? a:1 : '')], self)
endfunction
" }}}2
function! s:MRU_Prepare_Goto_File(...) dict "{{{2
  " mru_dir check find.
  if !filereadable(g:MRU_GotoFile)
    " mru_goto is create.
    call s:MRU_SaveList_Goto_File()
    if filereadable(g:MRU_GotoFile)
      call s:MRU_Msg_Success(g:MRU_GotoFile . ' is created.')
    else
      call s:MRU_Msg_Error(g:MRU_GotoFile . ' is not create.')
      return 0
    endif
  endif

  return 1
endfunction
" }}}2
" }}}1
" CmdFunc:Eval {{{1
function! s:MRU_LoadList_Eval() dict "{{{2
  " start with an empty list.
  if filereadable(g:MRU_Eval)
    let self.data = readfile(g:MRU_Eval)
    if self.data[0] =~# '^#'
      " Remove the comment line
      call remove(self.data, 0)
    endif
  else
    let self.data = []
  endif
endfunction "}}}2
function! s:MRU_Open_Window_Eval(...) dict "{{{2
  " load.
  call self.load()

  " Check for empty MRU list
  if empty(self.data)
    call s:MRU_Msg_Warning(self.bufname . ' list is empty.')
    return
  endif

  " If the window is already open, jump to it
  call s:MRU_AlreadyOpen_Window(self.bufname)

  call call('s:MRU_Env_SetLocal', a:000, self)
  " override hilight.
  set filetype=vim

  " Setup the cpoptions properly for the maps to work
  let old_cpoptions = &cpoptions
  set cpoptions&vim

  " keymap.
  call s:MRU_Env_Keymap()

  nnoremap <buffer> <silent> <2-LeftMouse> :call <SID>MRU_DoCmd('util', 'excmd')<CR>
  nnoremap <buffer> <silent> <CR> :call <SID>MRU_DoCmd('util', 'excmd')<CR>

  " Restore the previous cpoptions settings
  let &cpoptions = old_cpoptions

  " display.
  call call('s:MRU_Env_Display', [(a:0 > 0 ? a:1 : '')], self)
endfunction "}}}2
function! s:MRU_Prepare_Eval(...) dict "{{{2
  " mru_dir check find.
  if !filereadable(g:MRU_Eval)
    " mru_script is create.
    call s:MRU_SaveList_Eval()
    if filereadable(g:MRU_Eval)
      call s:MRU_Msg_Success(g:MRU_Eval . ' is created.')
    else
      call s:MRU_Msg_Error(g:MRU_Eval . ' is not create.')
      return 0
    endif
  endif

  return 1
endfunction "}}}2
" }}}1
" CmdFunc:Seek {{{1
function! s:MRU_LoadList_Seek(...) dict "{{{2
  " init
  let self.data = []
  let s:MRU_InputHistory = [] " before use init.

  if a:0 > 0
    if strlen(a:1) > 0
      if isdirectory(a:1)
        let l:dir = a:1
      else
        call s:MRU_Msg_Warning('Not directory.')
      endif
    else
      let l:dir = getcwd()
    endif
  else
    let l:dir = getcwd()
  endif

  while 1
    if !isdirectory(l:dir)
      call s:MRU_Msg_Warning('Directory deleted ... Quit.')
    endif

    if strlen(s:searchword) == 0
      call inputsave()
      let s:searchword = input("\[" . l:dir . "\]\nSeek > ")
      call inputrestore()
    endif

    if strlen(s:searchword) > 0
      if has('unix') || has('macunix')
        let self.data = split(system('find ' . l:dir . ' | grep ' . s:searchword), '\n')
      else
        let self.data = split(system('dir /B /S ' . s:searchword . ' /A-D'), '\n')
      endif

      if v:shell_error && !empty(self.data)
        if has('unix') || has('macunix')
          call s:MRU_Msg_Error("\n'find' Cmd execute error.(" . v:shell_error . ")")
        else
          call s:MRU_Msg_Error("\n'dir' Cmd execute error.(" . v:shell_error . ")")
        endif
        call s:MRU_Msg_Error('--------------------------------------------------')
        for l:v in self.data
          call s:MRU_Msg_Error(l:v)
        endfor
        let self.data = []
        break
      endif

      if empty(self.data)
        call s:MRU_Msg_Warning("\nNot Hit.")
        let s:searchword = ''
      else
        call add(s:MRU_InputHistory, s:searchword)
        break
      endif
    else
      call s:MRU_Msg_Success("\nQuit.")
      let s:searchword = ''
      break
    endif
  endwhile
endfunction "}}}2
function! s:MRU_Open_Window_Seek(...) dict "{{{2

  " load.
  setlocal nomore
  call call(self.load, a:000, self)

  " Check for empty MRU list
  if empty(self.data)
    return
  endif

  call s:MRU_AlreadyOpen_Window(self.bufname)

  call call('s:MRU_Env_SetLocal', a:000, self)
  setlocal number
  " Setup the cpoptions properly for the maps to work
  let old_cpoptions = &cpoptions
  set cpoptions&vim

  " keymap.
  call s:MRU_Env_Keymap()
  call s:MRU_Env_Keymap_OpenFile()
  
  " Restore the previous cpoptions settings
  let &cpoptions = old_cpoptions

  " display.
  call call('s:MRU_Env_Display', [(a:0 > 0 ? a:1 : '')], self)
endfunction "}}}2
function! s:MRU_Prepare_Seek(...) dict "{{{2
  " init
  let s:searchword = ''

  return 1
endfunction "}}}2
" }}}1
" CmdFunc:Locate {{{1
function! s:MRU_LoadList_Locate(...) dict "{{{2
  " init
  let self.data = []
  let s:MRU_InputHistory = [] " before use init.

  if len(g:MRU_Locate_NotInclude) > 0
    if has('unix') || has('macunix')
      let l:notinclude = "| grep -Ev '" . join(g:MRU_Locate_NotInclude, '|') . "'"
    else
      if has('win32')
        let l:notinclude = "^| findstr /v /i " . join(g:MRU_Locate_NotInclude, ' ')
      endif
    endif
  else
    let l:notinclude = ""
  endif

  while 1
    if strlen(s:searchword) == 0
      call inputsave()
      let s:searchword = input("Locate > ")
      call inputrestore()
    endif

    if strlen(s:searchword) > 0
      let self.data = split(system(g:MRU_Locate_Cmd . " -i " . s:searchword . l:notinclude), '\n')

      if v:shell_error
        call s:MRU_Msg_Error("\n'Locate' Cmd execute error.(" . v:shell_error . ")")
        call s:MRU_Msg_Error('--------------------------------------------------')
        for l:v in self.data
          call s:MRU_Msg_Error(l:v)
        endfor
        let self.data = []
        break
      endif

      if empty(self.data)
        call s:MRU_Msg_Warning("\nNot Hit.")
        let s:searchword = ''
      else
        call add(s:MRU_InputHistory, s:searchword)
        break
      endif
    else
      call s:MRU_Msg_Success("\nQuit.")
      let s:searchword = ''
      break
    endif
  endwhile
endfunction "}}}2
function! s:MRU_Open_Window_Locate(...) dict "{{{2

  " load.
  call call(self.load, a:000, self)

  " Check for empty MRU list
  if empty(self.data)
    return
  endif

  call s:MRU_AlreadyOpen_Window(self.bufname)

  call call('s:MRU_Env_SetLocal', a:000, self)
  setlocal number
  " Setup the cpoptions properly for the maps to work
  let old_cpoptions = &cpoptions
  set cpoptions&vim

  " keymap.
  call s:MRU_Env_Keymap()
  call s:MRU_Env_Keymap_OpenFile()
  
  " Restore the previous cpoptions settings
  let &cpoptions = old_cpoptions

  " display.
  call call('s:MRU_Env_Display', [(a:0 > 0 ? a:1 : '')], self)
endfunction "}}}2
function! s:MRU_Prepare_Locate(...) dict "{{{2
  " init
  let s:searchword = ''

  return 1
endfunction "}}}2
" }}}1
" CmdFunc:Netrw {{{1
function! s:MRU_LoadList_Netrw_Filer(...) dict "{{{2
  " init
  let self.data = []

  let l:dir = self.config_currentpath
  let self.data = split(system("ls -1apF " . l:dir), '\n')
  call filter(self.data, 'v:val !~# "^\.\/$"')
endfunction "}}}2
function! s:MRU_Open_Window_Netrw_Filer(...) dict "{{{2

  " load.
  call call(self.load, a:000, self)

  " Check for empty MRU list
  if empty(self.data)
    call s:MRU_Msg_Warning('Not Hit.')
    return
  endif

  call s:MRU_AlreadyOpen_Window(self.bufname)

  call call('s:MRU_Env_SetLocal', a:000, self)
  setlocal filetype=netrw
  " Setup the cpoptions properly for the maps to work
  let old_cpoptions = &cpoptions
  set cpoptions&vim

  " keymap.
  call s:MRU_Env_Keymap()
  call s:MRU_Env_Keymap_Netrw()
  
  " Restore the previous cpoptions settings
  let &cpoptions = old_cpoptions

  " display.
  call call('s:MRU_Env_Display', [(a:0 > 0 ? a:1 : '')], self)

  " buffer windows size full.
  resize

  " Hint
  call s:MRU_Msg_Success('<Hint> H key: Full size. / h key : Mini size.')
endfunction "}}}2
function! s:MRU_Prepare_Netrw_Filer(...) dict "{{{2
  " init
  let self.config_currentpath = getcwd()

  return 1
endfunction "}}}2
" }}}1
" CmdFunc:Mirror {{{1
function! s:MRU_LoadList_Mirror(...) dict "{{{2
  let self.data = []
  if exists('self.config_bufname')
    let self.data = getbufline(self.config_bufname, 1, '$')
  else
    call s:MRU_Msg_Error('self.config_bufname is not exists.')
  endif
endfunction "}}}2
function! s:MRU_Open_Window_Mirror(...) dict "{{{2

  " load.
  call call(self.load, a:000, self)

  " Check for empty MRU list
  if empty(self.data)
    call s:MRU_Msg_Warning('empty.')
    return
  endif

  call s:MRU_AlreadyOpen_Window(self.bufname)

  call call('s:MRU_Env_SetLocal', a:000, self)

  " Setup the cpoptions properly for the maps to work
  let old_cpoptions = &cpoptions
  set cpoptions&vim

  " keymap.
  call s:MRU_Env_Keymap()
  call s:MRU_Env_Keymap_Line()
  
  " Restore the previous cpoptions settings
  let &cpoptions = old_cpoptions

  " display.
  call call('s:MRU_Env_Display', [(a:0 > 0 ? a:1 : '')], self)
endfunction "}}}2
function! s:MRU_Prepare_Mirror(...) dict "{{{2
  let l:renew = 1

  for l:key in keys(s:MRU_Config)
    if s:MRU_Config[l:key].bufname == bufname('%')
      " not remember.
      let l:renew = 0
    endif
  endfor

  if l:renew == 1
    let self.config_bufname = bufnr('%')
  endif

  return 1
endfunction "}}}2
" }}}1
" CmdFunc:Base {{{1
function! s:MRU_Cmd_Base(key, ...) "{{{2
  if has_key(s:MRU_Config, a:key) == 1
    " fisrt initial :TODO
    if has_key(s:MRU_Config[a:key], 'window') == 0
      call s:MRU_Msg_Error('"s:MRU_Config[' . a:key . '].window" is not find.')
      return
    endif

    "  Every initial parametter.
    let s:MRU_ExecCmd = a:key
    call s:MRU_Env_Highlight()

    " prepare.
    if has_key(s:MRU_Config[a:key], 'prepare') == 1
      let r = call(s:MRU_Config[s:MRU_ExecCmd].prepare, a:000, s:MRU_Config[s:MRU_ExecCmd])
      if r == 0
        " not prepare.
        let s:MRU_ExecCmd = ''
        return 
      end
    end

    " execute.
    let b:saved_mru_search = @/
    call call(s:MRU_Config[s:MRU_ExecCmd].window, a:000, s:MRU_Config[s:MRU_ExecCmd])

    let s:MRU_ExecCmd = ''
    return
  else
    call s:MRU_Msg_Error('"' . a:key . '" is not find.')
  endif
endfunction "}}}2
function! s:MRU_Complete_Base(ArgLead, CmdLine, CursorPos) "{{{2
  let l:cmd = split(a:CmdLine, "[\t\ ]")

  if len(l:cmd) >= 2
    if has_key(s:MRU_Config, l:cmd[1]) == 1
      " first arg was input.
      if has_key(s:MRU_Config[l:cmd[1]], 'complete') == 1
        return s:MRU_Config[l:cmd[1]].complete(a:ArgLead, a:CmdLine, a:CursorPos, l:cmd[1])
      else
        " default is not complete.
        return []
      endif
    endif
  endif

  " first arg was not input.
  if a:ArgLead == ''
    " Return the complete list
    return s:MRU_Base_CompleteList
  else
    " Return only matching the specified pattern
    return filter(copy(s:MRU_Base_CompleteList), 'v:val =~? a:ArgLead')
  endif
endfunction "}}}2
" }}}1
function! s:MRU_Startup() "{{{1
  " Line continuation used here
  let s:cpo_save = &cpo
  set cpo&vim

  " Control to temporarily lock the MRU list. Used to prevent files from
  " getting added to the MRU list when the ':vimgrep' command is executed.
  let s:mru_list_locked = 0
  " save value.
  let b:saved_mru_search = ''
  " Default value settings.
  call s:MRU_Env_Var()

  if g:MRU_Use_StartupCheck_FileReadable
    " Check Readable mru_file, mru_dir.
    call s:MRU_Check_FileReadable('startup')
  endif

  call s:MRU_Env_AutoCmd()
  call s:MRU_Env_RegistCmd()

  " Complate-List initialize.
  for l:key in keys(s:MRU_Config)
    call add(s:MRU_Base_CompleteList, l:key)
    call sort(s:MRU_Base_CompleteList)
  endfor

  " restore 'cpo'
  let &cpo = s:cpo_save
  unlet s:cpo_save
endfunction "}}}1

" MRU Startup.
call s:MRU_Startup()

" vim:set foldenable foldmethod=marker:
