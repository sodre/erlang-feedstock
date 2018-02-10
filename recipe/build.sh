#!/usr/bin/env bash

export LIBRARY_PATH="${PREFIX}/lib:${LIBRARY_PATH}"
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"
export ERL_TOP="$(pwd)"
./otp_build autoconf
./configure --with-ssl="${PREFIX}" --prefix="${PREFIX}" --without-javac \
  --with-libatomic_ops="${PREFIX}" --enable-m${ARCH}-build
make -j $CPU_COUNT

# FIXME
#
# The tests appear to block upload on CircleCI.
# So we skip them on the Linux build. It would
# be nice to be able to run the tests again on
# Linux. Best guess is we might be missing
# some dependencies. See the linked issue.
#
# https://github.com/conda-forge/erlang-feedstock/issues/1
#
if [ "$(uname)" == "Darwin" ]
then
    make release_tests
    cd "${ERL_TOP}/release/tests/test_server"
    ${ERL_TOP}/bin/erl -s ts install -s ts smoke_test batch -s init stop
    cd ${ERL_TOP}
fi

make install
