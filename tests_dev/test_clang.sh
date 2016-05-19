#!/bin/bash -e
echo -e 'int main(){ return 0; }' | clang-3.8 -o /tmp/a.out -xc - && /tmp/a.out
