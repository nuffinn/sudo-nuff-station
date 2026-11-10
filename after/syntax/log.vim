" JSON-lines logs: log-highlight.nvim treats the value in {"level":"error"} as
" a plain string, so colour it by severity. These are defined after the
" plugin's LogString region, so they win when both start on the same quote.
syn match LogLvError    /\c\%("\%(level\|lvl\|severity\)"\s*:\s*\)\@32<="\%(fatal\|panic\|dpanic\|critical\|crit\|error\|err\)"/
syn match LogLvWarning  /\c\%("\%(level\|lvl\|severity\)"\s*:\s*\)\@32<="\%(warn\|warning\)"/
syn match LogLvInfo     /\c\%("\%(level\|lvl\|severity\)"\s*:\s*\)\@32<="\%(info\|notice\)"/
syn match LogLvDebug    /\c\%("\%(level\|lvl\|severity\)"\s*:\s*\)\@32<="\%(debug\|trace\)"/
