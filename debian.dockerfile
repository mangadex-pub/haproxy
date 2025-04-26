FROM docker.io/library/debian:bookworm AS base

# This stage is mostly to import and unpack the dists in a docker-friendly fashion
FROM base AS dists

RUN apt -qq update && apt install -qq -y bzip2

WORKDIR /tmp/dataplaneapi
COPY ./deps/dataplaneapi/dataplaneapi-dist.tar.gz /tmp/dataplaneapi/dataplaneapi.tar.gz
RUN ls -alh && tar xf dataplaneapi.tar.gz

ARG HAPROXY_SSL_LIB="awslc"
WORKDIR /tmp/${HAPROXY_SSL_LIB}
COPY ./deps/${HAPROXY_SSL_LIB}/${HAPROXY_SSL_LIB}-dist.tar.gz /tmp/${HAPROXY_SSL_LIB}/${HAPROXY_SSL_LIB}.tar.gz
RUN ls -alh && tar xf ${HAPROXY_SSL_LIB}.tar.gz

WORKDIR /tmp/haproxy
COPY ./haproxy/haproxy-dist.tar.gz /tmp/haproxy/haproxy.tar.gz
RUN ls -alh && tar xf haproxy.tar.gz

FROM base

LABEL Name="HAProxy"
LABEL Vendor="MangaDex"
LABEL Maintainer="MangaDex <opensource@mangadex.org>"

ARG CANONICAL_VERSION="local-SNAPSHOT"
LABEL Version="${CANONICAL_VERSION}"

ARG HAPROXY_SSL_LIB="awslc"
COPY --chown=root:root --from=dists /tmp/${HAPROXY_SSL_LIB}/opt /opt
COPY --chown=root:root --from=dists /tmp/dataplaneapi/usr /usr
COPY --chown=root:root --from=dists /tmp/haproxy/usr /usr

RUN apt -q update && \
    apt -qq -y --no-install-recommends install \
      ca-certificates \
      curl \
      libatomic1 \
      libjemalloc2 \
      libssl3 \
      procps \
      socat \
      zlib1g && \
    apt -qq -y --purge autoremove && \
    apt -qq -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/* /var/log/* && \
    groupadd "haproxy" && useradd -g "haproxy" "haproxy" && \
    /usr/local/sbin/haproxy -vv

CMD [ "/usr/local/sbin/haproxy", "-W", "-db", "-f", "/usr/local/etc/haproxy/haproxy.cfg" ]
