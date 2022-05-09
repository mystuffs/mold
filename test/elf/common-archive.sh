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
t=out/test/elf/$testname
mkdir -p $t

cat <<EOF | $CC -fcommon -xc -c -o $t/a.o -
#include <stdio.h>

int foo;
int bar;
extern int baz;
__attribute__((weak)) int two();

int main() {
  printf("%d %d %d %d\n", foo, bar, baz, two ? two() : -1);
}
EOF

cat <<EOF | $CC -fcommon -xc -c -o $t/b.o -
int foo = 5;
EOF

cat <<EOF | $CC -fcommon -xc -c -o $t/c.o -
int bar;
int two() { return 2; }
EOF

cat <<EOF | $CC -fcommon -xc -c -o $t/d.o -
int baz;
EOF

rm -f $t/e.a
ar rcs $t/e.a $t/b.o $t/c.o $t/d.o

$CC -B. -o $t/exe $t/a.o $t/e.a
$QEMU $t/exe | grep -q '5 0 0 -1'

cat <<EOF | $CC -fcommon -xc -c -o $t/f.o -
int bar = 0;
int baz = 7;
int two() { return 2; }
EOF

rm -f $t/f.a
ar rcs $t/f.a $t/b.o $t/f.o

$CC -B. -o $t/exe $t/a.o $t/f.a
$QEMU $t/exe | grep -q '5 0 7 2'

echo OK
