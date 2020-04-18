#!/bin/sh

rm init.txt
touch init.txt
echo -e "-- -*- mode: lua; -*-\n\n{\n\ndebugp = true -- debug printing\n" >> init.txt
for f in utility_functions.lua spells.lua resting_and_exploring.lua \
conditional_options.lua ready.lua; do cat $f; echo; done >> init.txt
echo -e "}\n" >> init.txt
cat options.txt >> init.txt
