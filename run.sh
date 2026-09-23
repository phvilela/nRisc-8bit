#!/bin/sh
iverilog src/*.v test/fib-test.v -o fib-test && vvp ./fib-test +N=${1:-10}
