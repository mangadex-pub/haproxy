FROM docker.io/rockylinux/rockylinux:9-minimal

LABEL Name="HAProxy"
LABEL Vendor="MangaDex"
LABEL Maintainer="MangaDex <opensource@mangadex.org>"

ARG CANONICAL_VERSION="local-SNAPSHOT"
LABEL Version="${CANONICAL_VERSION}"

COPY --chown=root:root haproxy/*.rpm /tmp

RUN microdnf -y update && \
    microdnf -y install epel-release && \
    microdnf --enablerepo=crb -y distro-sync && \
    microdnf --enablerepo=crb -y install \
      ca-certificates \
      curl \
      libatomic \
      jemalloc \
      procps-ng \
      socat \
      zlib zlib-ng && \
    rpm -ivh /tmp/*.rpm && \
    rm -v /tmp/*.rpm && \
    microdnf -y clean all && \
    /usr/local/sbin/haproxy -vv

# slight docker-specific working around
RUN rm -v /etc/default/haproxy && rm -rf /etc/haproxy
RUN mkdir -v /run/haproxy && chown haproxy:haproxy /run/haproxy
COPY --chown=root haproxy/haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

CMD [ "/usr/local/sbin/haproxy", "-W", "-db", "-f", "/usr/local/etc/haproxy/haproxy.cfg" ]
