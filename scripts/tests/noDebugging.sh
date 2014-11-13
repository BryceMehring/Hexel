#!/bin/bash

# Test to make sure that debugging is not enabled
enableDebuggingCount=($(grep -r "enableDebugging()" ../../ | wc -l))

if [ $enableDebuggingCount -gt 2 ]
then
  echo "Failed No Debugging Test"
  exit 1
fi

echo "Passed No Debugging Test"
