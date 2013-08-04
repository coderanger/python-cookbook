#!/usr/bin/env bats

@test "python: binary should exist" {
  type python
}

@test "python: binary should be Python 2" {
  [ "$(python -c 'print __import__("sys").version_info[0]')" -eq '2' ]
}

@test "python: pip should work" {
  python -m pip --version
}

@test "python: virtualenv should work" {
  python -m virtualenv --version
}

# CentOS doesn't have Python 3 packages
if [ -f /should_py3 ]; then

@test "python3: binary should exist" {
  type python3
}

@test "python3: binary should be Python 3" {
  [ "$(python3 -c 'print(__import__("sys").version_info.major)')" -eq '3' ]
}

fi

# Varied PyPy package support
if [ -f /should_pypy ]; then

@test "pypy: binary should exist" {
  type pypy
}

fi
