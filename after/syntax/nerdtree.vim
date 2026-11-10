" Dim Go test files (names ending in `test.go`) in the NERDTree window.
"
" This lives in after/syntax/ on purpose: `:set syntax=nerdtree` runs `syn clear`
" and then `runtime! syntax/nerdtree.vim`, which picks up after/ last. A FileType
" autocmd would be wiped by that `syn clear`, and matching from column 1 (like
" NERDTree's own NERDTreeFile item) means the item defined last wins.
" See lua/plugins/nerdtree.lua for the colour of NERDTreeGoTestFile.
"
" NERDTree prefixes node names with g:NERDTreeNodeDelimiter (^G when 'conceal'
" is available) and may append it again before the [flags]; anchoring the match
" on the delimiter or end of line keeps `latest.gob` and friends untouched.
if exists('g:NERDTreeNodeDelimiter') && !empty(g:NERDTreeNodeDelimiter)
    let s:tail = '%(%d' . char2nr(g:NERDTreeNodeDelimiter) . '|$)'
else
    let s:tail = '$'
endif

exec 'syn match NERDTreeGoTestFile #\v^ +.*test\.go\ze' . s:tail . '#'

unlet s:tail
