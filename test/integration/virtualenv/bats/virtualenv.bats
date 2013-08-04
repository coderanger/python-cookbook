#!/usr/bin/env bats

@test "virtualenv should exist" {
  [ -f /venv ]
}

@test "virtualenv should be activatable" {
  ( source /venv/bin/activate && true )
}

@test "python2: virtualenv should exist" {
  [ -f /venv2 ]
}

@test "python2: virtualenv should be activatable" {
  ( source /venv2/bin/activate && true )
}

@test "python2b: virtualenv should exist" {
  [ -f /venv2b ]
}

@test "python2b: virtualenv should be activatable" {
  ( source /venv2b/bin/activate && true )
}
