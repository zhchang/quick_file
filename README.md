quick_file
==========

jump to files, even though you might not remember the full path and / or the full name

vim.org link:
http://www.vim.org/scripts/script.php?script_id=4980

NEED VIM WITH PYTHON SUPPORT!!!
===============================

:QF filename-fragment

the plugin will try to jump to shallowest match under current directory and it's sub directories. Also, it is possible to provide more details for a deeper match.

let's say we have a/c.txt a/b/c.txt

:QF c will jump to a/c.txt and start editing
:QF c b will jump to a/b/c.txt
