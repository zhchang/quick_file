if !has('python')
    finish
endif

function! QuickFile(...)
python << endpython
import vim
import os
import glob
import fnmatch

def test(matches, args):
    name = '*%s*'%(args[0])
    others = args[1:]
    match = None
    count = 0
    for root,dir,files in os.walk(pwd):
        for file in fnmatch.filter(files,name):
            pre, ext = os.path.splitext(file)
            if ext in ['pyc','swp','class'] or pre.startswith('.'):
                continue
            path = os.path.join(root,file)
            found = True
            for other in others:
                if path.find(other) == -1:
                    found = False
                    break;
            if found:
                match = path
                return match
    return match


args = vim.eval("a:000")
pwd = vim.eval('getcwd()')
if len(args) > 0:
    match = test(pwd,args)
    if match is not None: 
        vim.command('e %s'%(match))
endpython
endfunction

command! -nargs=* QF call QuickFile(<f-args>)
