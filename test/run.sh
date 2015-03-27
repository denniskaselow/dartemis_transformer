#!/bin/bash

# Fast fail the script on failures.   
set -e

# Run the tests.
dart --checked test/all_tests.dart

# Install dart_coveralls; gather and send coverage data.
if [ "$COVERALLS_TOKEN" ]; then
  pub global activate dart_coveralls
  pub global run dart_coveralls report \
    --token $COVERALLS_TOKEN \
    --retry 2 \
    --exclude-test-files \
    test/all_tests.dart
fi