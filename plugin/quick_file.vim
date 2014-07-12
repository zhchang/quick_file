if !has('python')
    finish
endif

function! QuickFile(...)
python << endpython
from __future__ import division
import vim
import os
import glob
import fnmatch
import time

def test(pwd, args, timeout):
    name = '*%s*'%(args[0])
    others = args[1:]
    count = 0
    start = time.time()
    for root,dir,files in os.walk(pwd):
        if (time.time() - start) >= timeout:
            print 'Timeout'
            return None
        for file in fnmatch.filter(files,name):
            if (time.time() - start) >= timeout:
                print 'Timeout'
                return None
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
                return path
    print 'No file found'
    return None

args = vim.eval("a:000")
pwd = vim.eval('getcwd()')
if len(args) > 0:
    match = test(pwd, args, 3)
    if match is not None: 
        vim.command('e %s'%(match))
endpython
endfunction

command! -nargs=* QF call QuickFile(<f-args>)
