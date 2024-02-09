# 

## Context

In Alice & Bob's physics laboratory, instruments output data as streams. These
streams must then be read and processed to obtain meaningful results.

This exercise aims at implementing such a data processing: given a certain
window size, we want to compute the *(central) moving average* of the data:

```
input data:                     2.    2.    2.    5.    4.
output (moving avg, window=3):        2.    3.    3.666
```

You are given a data stream through [named pipes](https://en.wikipedia.org/wiki/Named_pipe).
This is the `datastream.sh` utility script.
You can think of a data stream as a job producing numerical data as it is
running and sending it to the pipe.

There can be one or multiple data streams, running either sequentially (one
after the other), or running in parallel.
The data streams can send data either synchronously (i.e. in one shot, when the
reader is ready) or asynchronously over a longer time period.
The numerical data is stored in binary data, as doubles (standard size,
little-endian).

> Note: in the case of a single data stream, the data streams can also use
> stdout instead of a named pipe

```shell
$ # Start a single data stream outputting the content of 'sample-data-in' to stdout
$ ./datastream.sh data/sample-data-in,-
?@@

$ # If we had a 'decode_binary.py' utility script, it would look like that:
$ ./datastream.sh data/sample-data-in,- | python decode_binary.py
0.0
1.0
2.0
3.0
4.0

$ # Start 2 data streams sequentially, outputting the same data to 2 named pipes 
$ # `output1` and `output1`
$ ./datastream.sh data/sample-data-in,output1 data/sample-data-in,output2
$ # In a separate terminal, we could run `cat output1`, then `cat output2` to
$ # retrieve the content of 'sample-data-in'
```

## Instructions

Starting from the code in `processing/run.py`, you should implement a
CLI tool that can:

* process the data streams described above
* compute the moving average
* output the data in a binary file.

You are provided with some boilerplate code to help you start, but you may
need to rewrite it to support the more complex cases.

Your solution should support this API:

```shell
# Process 2 incoming datastreams, where:
# * 3 is the moving average window size for the first data stream
# * `input1` is the name of the input named pipe for the first data stream
#   (or '-' for stdin)
# * `output1` is the name of the output binary file for the first data stream 
#   (or '-' for stdout), containing your computation results
python3 processing/run.py 3,input1,output1 5,input2,output2
```

The `tests/test_processing_cli.py` file contains tests for some of the use
cases described above.
We do not necessarily expect your solution to pass all these tests.
But please keep in mind that a simple solution that works on basic test cases
is better than a more generic solution that does not pass any tests.

Also, please keep in mind that documentation and testing are part of the
assessment: we expect you to explain your choices and write additional tests
if you can.

Good luck!
