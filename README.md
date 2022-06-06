# HAProxy

Build scripts for HAProxy with QUIC

**PROJECT STATUS: Alpha, __not exhaustively tested yet__**

## Quickstart

**NOTE FOR QUIC:** docker and docker-compose require explicit UDP protocol port mapping, otherwise they assume only-TCP. See below.

```shell
docker run -it \
    -v /path/to/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro \
    -p "80:80" \
    -p "443:443/tcp" \
    -p "443:443/udp" \
    registry.gitlab.com/mangadex-pub/haproxy:2.6-bullseye
```

Here's a sample configuration (requires you to figure out the certificate) to test HTTP/3.0 support. The first connection should be over HTTP/1.1 or HTTP/2, and
after a few refreshes it should be over HTTP/3.

See [Announcing HAProxy 2.6](https://www.haproxy.com/blog/announcing-haproxy-2-6/) for more info.

```haproxy
...
frontend https
    bind       :443 ssl crt /usr/local/etc/haproxy/cert.pem alpn h2,http/1.1
    bind quic4@:443 ssl crt /usr/local/etc/haproxy/cert.pem alpn h3
    
    http-after-response set-header alt-svc 'h3=":443"; ma=86400'
    http-request return status 200 content-type text/plain lf-string "Connected via %HV"
```

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
