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
import threading
from sys import platform as _platform
import subprocess

out=''
error='time out'
p = None


def getEPath(thing):
    if _platform.find('linux') == 0 or _platform == 'darwin':
        return thing.replace(' ','\ ')
    else:
        return '"%s"'%(thing)
        
def find(pwd, args, timeout):
    if _platform.find('linux') == 0 or _platform == 'darwin':
        name = '*%s*'%(args[0])
        others = args[1:]
        inputs = 'find . -type f -name "%s" '%(name)
        for ignore in ['*.pyc','*.swp','*.class']:
            inputs += '-and -not -name "%s"'%(ignore)
        for other in others:
            inputs += '|grep %s'%(other)
        def _target():
            global out
            global p
            p = subprocess.Popen(inputs,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
            out,err=p.communicate()
            global error
            error = 'not found'
	thread = threading.Thread(target=_target)
        thread.start()
        thread.join(timeout)
        if error == 'time out':
            try:
                p.kill()
            except:
                pass
        things = out.split('\n')
        if things is not None and len(things)>0:
            things = [x for x in things if len(x) > 0]
            if len(things)>0:
                things.sort(lambda x,y: cmp(len(x),len(y)))
                match = getEPath(things[0])
                #print match
                return match
        print error
        return None
    else:
        return winfind(pwd,args,timeout)

def winfind(pwd, args, timeout):
    name = '*%s*'%(args[0])
    others = args[1:]
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
                return getEPath(path)
    print 'No file found'
    return None

args = vim.eval("a:000")
pwd = vim.eval('getcwd()')
if len(args) > 0:
    match = find(pwd, args, 3)
    if match is not None: 
        vim.command('e %s'%(match))
endpython
endfunction

command! -nargs=* QF call QuickFile(<f-args>)
