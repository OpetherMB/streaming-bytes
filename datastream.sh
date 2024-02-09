#!/bin/bash

# Utility script to mimic one or multiple data streams, by piping the content
# of existing files to stdout or to named pipes.
#
# Usage:
#
#   ./datastream.sh [-p] [stream...]
#
# With
#   -p : Option to run the datastreams in parallel (by default, if not
#        specified, they will be run one after the other)
#   stream: For each desired stream, format should be
#       '<file_in>,<file_out>[,<n>]'
#     file_in: The name or path to the input file. Can be '-' for stdin
#     file_out: The name or path of the output named pipe. Can be '-' for stdout.
#     n: Optional. If specified, repeat the content of file_in n times.

cat_data() {
  in_file=$1
  n=$2
  for ((i = 0; i < n; i++)); do
    cat "$in_file"
  done
}

pipe_data() {
  in_file=$1
  out_file=$2
  n=$3

  if [ "$out_file" = "-" ]; then
    #    use stdout
    cat_data "$in_file" $n
  else
    #    use a FIFO
    if [ -e "$out_file" ]; then
      rm -f "$out_file"
    fi
    mkfifo "$out_file"
    cat_data "$in_file" $n >"$out_file"
  fi
}

PARALLEL=false
while getopts ":p" opt; do
  case $opt in
  p)
    PARALLEL=true
    shift
    ;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    ;;
  esac
done

for args in "$@"; do
  #  Input file
  in_file="$(echo "$args" | cut -d',' -f1)"
  #  Output file (can be a real file or just '-' for stdout)
  out_file="$(echo "$args" | cut -d',' -f2)"
  #  Optional: repeat the input file multiple times (by default, 1)
  n="$(echo "$args" | cut -d',' -f3)"
  n="${n:-1}"

  if [ $PARALLEL == true ]; then
    pipe_data $in_file $out_file $n &
  else
    pipe_data $in_file $out_file $n
  fi
done
  