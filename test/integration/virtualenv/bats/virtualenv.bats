#!/usr/bin/env bats

@test "virtualenv should exist" {
  [ -d /venv ]
}

@test "virtualenv should be activatable" {
  ( source /venv/bin/activate && true )
}

@test "python2: virtualenv should exist" {
  [ -d /venv2 ]
}

@test "python2: virtualenv should be activatable" {
  ( source /venv2/bin/activate && true )
}

@test "python2b: virtualenv should exist" {
  [ -d /venv2b ]
}

@test "python2b: virtualenv should be activatable" {
  ( source /venv2b/bin/activate && true )
}

@test "python2c: virtualenv should be owned by venv2c" {
  [ "$(stat -c %U /venv2c/venv)" = venv2c ]
}
