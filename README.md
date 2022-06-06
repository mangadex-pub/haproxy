# HAProxy

Build scripts for HAProxy with QUIC

## Get started

You will need the following dependencies (Debian/Ubuntu packages given as example):

- Development tools (`build-essential`)
- curl and ssl support for it (`curl` and `ca-certificates`)
- CMake (`cmake`)
- Readline library headers (`libreadline-dev`)
- Libsystemd headers (`libsystemd-dev`)
- GNU TAR (`tar`)

Then just run `make` and the build should pass.

You then need to unpack `deps/quictls/quictls-OpenSSL_1_1_1o-dist.tar.gz` so
that it expands in `/opt/quictls`, which is where HAProxy will look for OpenSSL.

And finally you can expand `haproxy/haproxy-2.6-dist.tar.gz` wherever you please.

## Should I use this repo?

This is an:
- unofficial build of HAProxy
- which enables an experimental feature of HAProxy
- which relies on an unofficial build of OpenSSL
- which is based on an unofficial patch of OpenSSL

Generally speaking, you shouldn't.

That said, please PR improvements back if you do. We'll be using it ourselves too.

## What's in there

First, we want to statically build things where possible, which is done for:
- LUA
- PCRE2
- QuicTLS

Then we want HAProxy to not use the system's OpenSSL but rather our QuicTLS build, which
it will look for at the `/opt/quictls` prefix.
