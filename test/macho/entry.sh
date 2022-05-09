#!/bin/bash
export LC_ALL=C
set -e
CC="${CC:-cc}"
CXX="${CXX:-c++}"
GCC="${GCC:-gcc}"
GXX="${GXX:-g++}"
OBJDUMP="${OBJDUMP:-objdump}"
MACHINE="${MACHINE:-$(uname -m)}"
testname=$(basename "$0" .sh)
echo -n "Testing $testname ... "
cd "$(dirname "$0")"/../..
t=out/test/macho/$testname
mkdir -p $t

cat <<EOF | $CC -o $t/a.o -c -xc -
#include <stdio.h>

int hello() {
  printf("Hello world\n");
  return 0;
}
EOF

clang --ld-path=./ld64 -o $t/exe $t/a.o -Wl,-e,_hello
$t/exe | grep -q 'Hello world'

! clang --ld-path=./ld64 -o $t/exe $t/a.o -Wl,-e,no_such_symbol 2> $t/log || false
grep -q 'undefined entry point symbol: no_such_symbol' $t/log

echo OK
