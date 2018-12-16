# mru.vim
--------------------

## Description
"mru" is the abbreviation for "most recent used". 
This plug-in is improving "[mru.vim](http://www.vim.org/scripts/script.php?script_id=521)".
(The version made into origin is "3.3")

--------------------
## Purpose
It is the purpose to create convenience and a simple user interface for the basic operation used frequently. 
The user interface of "[mru.vim](http://www.vim.org/scripts/script.php?script_id=521)" is easy to operate, easy-to-use, and very good. 

--------------------

## Installation
1. Extract the file and put files in your Vim directory.(ex. $VIMRUNTIME directory)
2. "history file" is created at the first time start-up of "VIM".  
It is created by the place of the value of "`g:MRU_File`,`g:MRU_Directory`".

### USAGE
Exceute Commands.  

`:Mru [args]` " Refer to the following for an argument. 

 > File
 > Dir
 > Buffer
 > Mark
 > NetrwBookmark
 > NetrwHistory
 > NetrwFiler
 > GotoFile
 > Eval
 > Seek
 > Locate
 > Mirror

`:MruLinkRotCheck`  "link rot check.

`:MruStatus` " show Mru settings parametter.

--------------------

