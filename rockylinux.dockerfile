FROM docker.io/rockylinux/rockylinux:9-minimal

LABEL Name="HAProxy"
LABEL Vendor="MangaDex"
LABEL Maintainer="MangaDex <opensource@mangadex.org>"

ARG CANONICAL_VERSION="local-SNAPSHOT"
LABEL Version="${CANONICAL_VERSION}"

COPY --chown=root:root haproxy/*.rpm /tmp

RUN microdnf -y update && \
    microdnf -y install dnf && \
    dnf -y install epel-release && \
    /usr/bin/crb enable && \
    dnf -y distro-sync && \
    dnf -y install \
      ca-certificates \
      curl \
      libatomic \
      jemalloc \
      procps-ng \
      socat \
      zlib zlib-ng && \
    dnf -y install /tmp/*.rpm && \
    rm -v /tmp/*.rpm && \
    dnf -y autoremove && \
    dnf -y clean all && \
    /usr/local/sbin/haproxy -vv

# slight docker-specific working around
RUN rm -v /etc/default/haproxy && rm -rf /etc/haproxy
RUN mkdir -v /run/haproxy && chown haproxy:haproxy /run/haproxy
COPY --chown=root haproxy/haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

CMD [ "/usr/local/sbin/haproxy", "-W", "-db", "-f", "/usr/local/etc/haproxy/haproxy.cfg" ]
