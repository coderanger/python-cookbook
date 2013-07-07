#!/usr/bin/env bats

@test "python3 binary should exist" {
  type python3
}

@test "python3 binary should be Python 3" {
  [ "$(python3 -c 'print(__import__("sys").version_info.major)')" -eq '3' ]
}
