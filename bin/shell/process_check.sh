#!/bin/bash

function process_check {
  if [ -z "$1" ]; then
    echo "Please provide the process name"
    exit 1
  fi

  if pgrep -x "$1" >/dev/null; then
    echo "Process $1 is running"
  else
    echo "Process $1 is not running"
  fi
}

process_check "$1"
