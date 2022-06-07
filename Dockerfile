FROM docker.io/library/debian:bullseye as base

# This stage is mostly to import and unpack the dists in a docker-friendly fashion
FROM base as dists

RUN apt -qq update && apt install -qq -y bzip2

WORKDIR /tmp/quictls
COPY ./deps/quictls/quictls-dist.tar.gz /tmp/quictls/quictls.tar.gz
RUN ls -alh && tar xf quictls.tar.gz

WORKDIR /tmp/haproxy
COPY ./haproxy/haproxy-dist.tar.gz /tmp/haproxy/haproxy.tar.gz
RUN ls -alh && tar xf haproxy.tar.gz

FROM base

LABEL Name=HAProxy
LABEL Vendor=MangaDex
MAINTAINER MangaDex <opensource@mangadex.org>

ARG CANONICAL_VERSION="local-SNAPSHOT"
LABEL Version=${CANONICAL_VERSION}

COPY --chown=root:root --from=dists /tmp/quictls/opt /opt
COPY --chown=root:root --from=dists /tmp/haproxy/usr /usr

RUN apt -q update && \
    apt -qq -y --no-install-recommends install \
      ca-certificates \
      curl \
      libatomic1 \
      libssl1.1 \
      libsystemd0 \
      procps \
      socat \
      zlib1g && \
    apt -qq -y --purge autoremove && \
    apt -qq -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/* /var/log/* && \
    groupadd "haproxy" && useradd -g "haproxy" "haproxy" && \
    /opt/quictls/bin/openssl version && \
    /usr/local/sbin/haproxy -vv

CMD [ "/usr/local/sbin/haproxy", "-W", "-db", "-f", "/usr/local/etc/haproxy/haproxy.cfg" ]
