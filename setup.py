#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
from setuptools import setup

pkg_name = 'bjodah'

release_py_path = os.path.join(pkg_name, '_release.py')

BJODAH_RELEASE_VERSION = os.environ.get('BJODAH_RELEASE_VERSION', '')  # v*
if len(BJODAH_RELEASE_VERSION) > 0:
    if BJODAH_RELEASE_VERSION[0] == 'v':
        TAGGED_RELEASE = True
        __version__ = BJODAH_RELEASE_VERSION[1:]
    else:
        raise ValueError("Ill formated version")
else:
    TAGGED_RELEASE = False
    # read __version__ attribute from _release.py:
    exec(open(release_py_path).read())

setup(
    name='bjodah',
    packages=[pkg_name],
    version=__version__,
    description='bjodahimg commandline tool',
    author='Björn Dahlgren',
    author_email='bjodah@DELETEMEgmail.com',
    include_package_data=True,
    entry_points={
        'console_scripts': ['bjodah=bjodah:main']
    },
    install_requires=['argh']
)
