if !has('python')
    finish
endif

function! QuickFile(...)
python << endpython
from __future__ import division
import vim
import subprocess
import threading
import vim
import os
import glob
import fnmatch
import time
from sys import platform as _platform

class Command(object):
    def __init__(self, pwd, args):
        name = '*'
        for arg in args:
            name += arg + '*'
        self.cmd = ['find', pwd, '-name', name]
        self.process = None

    def run(self, timeout):
        def target():
            self.process = subprocess.Popen(self.cmd, stdout=subprocess.PIPE)
            self.result = self.process.communicate()
        thread = threading.Thread(target=target)
        thread.start()
        thread.join(timeout)
        terminated_by_timeout = False
        if thread.is_alive():
            terminated_by_timeout = True
            self.process.terminate()
            thread.join()
        if self.process.returncode == 0 or len(self.result[0]) > 0:
            return 0, self.result[0]
        elif terminated_by_timeout:
            return -1, 'Timeout'
        else:
            return self.process.returncode, 'Error'

def find_match(pwd, args, timeout):
    command = Command(pwd, args)
    result = command.run(timeout)
    if result[0] != 0:
        print result[1]
    else:
        def check_path(path):
            if path is None or len(path) == 0:
                return False
            basename = os.path.basename(path)
            # folders
            if not os.path.isfile(path):
                return False
            # hidden files
            if len(basename) == 0 or basename.startswith('.'):
                return False
            # binary files
            ext = basename.split('.')[-1].lower()
            return not ext in binary_extensions

        list_of_matches = result[1].split('\n')
        binary_extensions = ['swp', 'pyc', 'class', 'jpeg', 'jpg', 'png']
        the_one = filter(check_path, list_of_matches)
        if len(the_one) > 0:
            return the_one[0]
        else:
            print 'Not found'
    return None

args = vim.eval("a:000")
pwd = vim.eval('getcwd()')
if len(args) > 0:
    match = find_match(pwd, args, 3)
    if match is not None: 
        vim.command('e %s'%(match))
endpython
endfunction

command! -nargs=* QF call QuickFile(<f-args>)

