# HAProxy

Build scripts for HAProxy with QUIC

**PROJECT STATUS: STABLE**. We have been using it in our own production systems
for months now without issues. If you rely on it for critical purposes, maintain
your own fork, so that a potential tagging/CI issue doesn't cause you problems.

[[_TOC_]]

## Quickstart

```shell
docker run -it \
    -v /path/to/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro \
    -p "80:80" \
    -p "443:443/tcp" \
    -p "443:443/udp" \
    registry.gitlab.com/mangadex-pub/haproxy:2.7-stable-bullseye
```

## HTTP/3 and QUIC

**NOTE FOR QUIC:** docker and docker-compose require explicit UDP protocol port
mapping, otherwise they assume only-TCP. See the explicit port-mapping above.

Here's a sample configuration (requires you to figure out the certificate) to
test HTTP/3.0 support. The first connection should be over HTTP/1.1 or HTTP/2,
and
after a few refreshes it should be over HTTP/3.

See [Announcing HAProxy 2.6](https://www.haproxy.com/blog/announcing-haproxy-2-6/)
for more info.

```haproxy
...
frontend https
    bind       :443 ssl crt /usr/local/etc/haproxy/cert.pem alpn h2,http/1.1
    bind quic4@:443 ssl crt /usr/local/etc/haproxy/cert.pem alpn h3

    http-after-response set-header alt-svc 'h3=":443"; ma=86400'
    http-request return status 200 content-type text/plain lf-string "Connected via %HV"
```

## Build it

You will need the following dependencies (Debian/Ubuntu packages given as
example):

- Development tools (`build-essential`)
- curl and ssl support for it (`curl` and `ca-certificates`)
- CMake (`cmake`)
- Readline library headers (`libreadline-dev`)
- Libsystemd headers (`libsystemd-dev`)
- GNU TAR (`tar`)

Then just run `make` and the build should pass.

First, `deps/quictls/quictls-dist.tar.gz` should be expanded so it matches the
host's
`/opt/quictls` when expanding, as it is where HAProxy will look for OpenSSL.

And finally `haproxy/haproxy-dist.tar.gz` can be expanded anywhere.

## Compatibility of binaries

You may acquire binaries for non-docker usage in 2 ways:

- We distribute binary tarballs for this repo in
  the [project's packages](https://gitlab.com/mangadex-pub/haproxy/-/packages)
- You can build it locally, which results in `deps/quictls/quictls-dist.tar.gz`
  and `haproxy/haproxy-dist.tar.gz`

Please note that neither QuicTLS/OpenSSL nor HAProxy are fully statically
compiled. They are still linking to glibc. You see that
with `readelf -d /path/to/binary`.

As a result, you may be unable to run a binary linked using a more recent glibc.

Our CI uses the most recent Debian Buster image for compilation. You can find
out the exact libc version this links against with `ldd --version` like so:

```shell
$ docker run -it debian:buster ldd --version | head -n1
ldd (Debian GLIBC 2.28-10+deb10u1) 2.28
```

Particular care should thus be put in what host you use for compilation.

Similarly, if you generally enjoy running abandonware you will not be able to
use any of our non-docker artifacts.

## Should I use this repo?

This is an:

- unofficial build of HAProxy
- which enables an experimental feature of HAProxy
- which relies on an unofficial build of OpenSSL
- which is based on an unofficial patch of OpenSSL

Generally speaking, you shouldn't.

That said, please PR improvements back if you do. We'll be using it ourselves
too.

## What's in there

First, we want to statically build things where possible, which is done for:

- LUA
- PCRE2
- QuicTLS (*partially*, still links to host glibc)

Then we want HAProxy to not use the system's OpenSSL but rather our QuicTLS
build, which
it will look for at the `/opt/quictls` prefix.

## About Debian packaging

The content of [haproxy/debian](haproxy/debian) is a slightly modified version
of the Debian HAProxy Team's work and essentially all credits wrt that is due to
them.

It is sourced
from [haproxy-team/haproxy:experimental-2.6](https://salsa.debian.org/haproxy-team/haproxy/-/tree/experimental-2.6)

## Notes

Since we're building our own binaries, we also increase MAX_SESS_STKCTR to 5
instead of the default of 3. If you don't know what that is, it's irrelevant to
you. You can read some
more [here](https://github.com/haproxy/haproxy/issues/1565).
