## Static html page generator CLoveR.Jr
CLoveR.Jr (ChangeLog over Ruby Jr) will generate an html file from a Changelog file.

## How to start
```
bundle install
```
Then try following command.
```
ruby cloverjr.rb ./contents/sample.chg
```
## What is "changelog" ?
Changelog is one of the text format which is used to track daily change.
CLoveR.Jr will convert Changelog into an html file.
A few modification required on changelog format.

- Dateformat
- Title + tag format
- image markdown

"contents" directory has sample changelog file.
It's looks like below.
```
2020-07-17  hassy
	* English sample [tags%English%sample]:  
	## heading h2
	### heading h3
	#### Headingしh4
	##### Heading h5
	Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
	
	- List
	- of the list
```

First line shows "date" and "author". Date format should be YYYY-MM-DD.
Next line shows "Title" and "tags" terminated by ":".
```
<tab>* title [tags%tag%separated%by%]:
```
after that "mark-down" contents follows.
```
<tab> mark-down contents line1
<tab> mark-down contents line2
:
```
## VIM supports change log format
If you use vim as editor, change log format is supported by vim.
Put followings on your .vimrc.
```
let g:changelog_timeformat="%Y-%m-%d"
let g:changelog_username ="<your name>"
autocmd BufRead *.chg set filetype=changelog
autocmd FileType changelog set foldexpr=ChgLogFoldLevel(v:lnum) foldmethod=expr foldlevel=0 textwidth=0

" for changelog folding"
function! ChgLogFoldLevel(lnum)
       	let l1 = getline(a:lnum)  
	if l1 =~"^\\t\\*[^*]"
	       	return '>1'
       	elseif l1 =~"^\\t"
	       	return 1
       	else
	       	return 0
       	endif
endfunction
```

##  blog for CLoveR and CLoveR.Jr (Japanese)
my blog uses CLoveR.
[Dream Driven Development](https://dream.drivendevelopment.jp/)
