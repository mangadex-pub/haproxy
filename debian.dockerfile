FROM docker.io/library/debian:bookworm

LABEL Name="HAProxy"
LABEL Vendor="MangaDex"
LABEL Maintainer="MangaDex <opensource@mangadex.org>"

ARG CANONICAL_VERSION="local-SNAPSHOT"
LABEL Version="${CANONICAL_VERSION}"

COPY --chown=root:root haproxy/*.deb /tmp

RUN apt-get -q update && \
    apt-get -qq -y --no-install-recommends install \
      ca-certificates \
      curl \
      libatomic1 \
      libjemalloc2 \
      libssl3 \
      procps \
      socat \
      zlib1g && \
    dpkg -i /tmp/*.deb && \
    rm -v /tmp/*.deb && \
    apt-get -qq -y install -f && \
    apt-get -qq -y --purge autoremove && \
    apt-get -qq -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/* /var/log/* && \
    /usr/local/sbin/haproxy -vv

# slight docker-specific working around
RUN rm -v /etc/default/haproxy && rm -rf /etc/haproxy
RUN mkdir -v /run/haproxy && chown haproxy:haproxy /run/haproxy
COPY --chown=root haproxy/haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

CMD [ "/usr/local/sbin/haproxy", "-W", "-db", "-f", "/usr/local/etc/haproxy/haproxy.cfg" ]
