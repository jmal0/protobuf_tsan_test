#!/bin/bash
set -e

# Rebuild between runs
rm -f protobuf_tsan_test 

LINK_FLAGS="-L /usr/local/lib64/ -lprotobuf -labsl_hash -labsl_log_internal_check_op -labsl_log_internal_message"
# Debug protobuf link flags:
#LINK_FLAGS="-L /usr/local/lib64/ -lprotobufd -labsl_hash -labsl_log_internal_check_op -labsl_log_internal_message"
g++ main.cpp -o protobuf_tsan_test ${LINK_FLAGS} -fsanitize=thread
# Works with clang though??
clang++ main.cpp -o protobuf_tsan_test ${LINK_FLAGS} -fsanitize=thread
# Run simple example which triggers an abort
LD_LIBRARY_PATH=/usr/local/lib64 ./protobuf_tsan_test
