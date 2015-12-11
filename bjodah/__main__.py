#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Command line tool for launching docker containers based on bjodah/bjodahimg
"""
from __future__ import (absolute_import, division, print_function)


import argh
import subprocess
import pkg_resources

from . import __version__

def build(tag='latest', inp='input/', out='output/', cmd="make"):
    """ Build out-of-tree with readonly input """
    build_script = pkg_resources.resource_filename(__name__, 'scripts/build.sh')
    subprocess.check_call([build_script, inp, out, cmd, tag])

argh.dispatch_commands([func for name, func in locals().items()
                        if not name.startswith('__') and callable(func)])
