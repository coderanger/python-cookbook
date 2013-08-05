#!/usr/bin/env bats

@test "python: binary should exist" {
  type python
}

@test "python: binary should be Python 2" {
  [ "$(python -c 'print __import__("sys").version_info[0]')" -eq '2' ]
}

@test "python: pip should work" {
  python -c "import pip"
}

@test "python: virtualenv should work" {
  python -c "import virtualenv"
}

# CentOS doesn't have Python 3 packages
if [ -f /should_py3 ]; then

@test "python3: binary should exist" {
  type python3
}

@test "python3: binary should be Python 3" {
  [ "$(python3 -c 'print(__import__("sys").version_info.major)')" -eq '3' ]
}

PY3_VERSION="$(python3 -c 'print(".".join(str(n) for n in __import__("sys").version_info[0:2]))')"
if [ "$PY3_VERSION" != "3.0" -a "$PY3_VERSION" != "3.1" ]; then

@test "python3: pip should work" {
  python3 -m pip --version
}

fi

@test "python3: virtualenv should work" {
  python3 -m virtualenv --version
}

fi

# Varied PyPy package support
if [ -f /should_pypy ]; then

@test "pypy: binary should exist" {
  type pypy
}

@test "pypy: pip should work" {
  pypy -m pip --version
}

@test "pypy: virtualenv should work" {
  pypy -m virtualenv --version
}

fi
