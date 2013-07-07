#!/usr/bin/env bats

@test "python binary should exist" {
  type python
}

@test "python binary should be Python 2" {
  [ "$(python -c 'print __import__("sys").version_info[0]')" -eq '2' ]
}
