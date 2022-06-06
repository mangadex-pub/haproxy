# HAProxy

Build scripts for HAProxy with QUIC

**PROJECT STATUS**: Alpha, untested, probably unstable

## Quickstart

    docker run -it -v /path/to/haproxy.cfg:/etc/haproxy/haproxy.cfg:ro registry.gitlab.com/mangadex-pub/haproxy:2.6-bullseye

## Build it

You will need the following dependencies (Debian/Ubuntu packages given as example):

- Development tools (`build-essential`)
- curl and ssl support for it (`curl` and `ca-certificates`)
- CMake (`cmake`)
- Readline library headers (`libreadline-dev`)
- Libsystemd headers (`libsystemd-dev`)
- GNU TAR (`tar`)

Then just run `make` and the build should pass.

First, `deps/quictls/quictls-dist.tar.gz` should be expanded so it matches the host's
`/opt/quictls` when expanding, as it is where HAProxy will look for OpenSSL.

And finally `haproxy/haproxy-dist.tar.gz` can be expanded anywhere.

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
