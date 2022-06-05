ARG DEBIAN_CODENAME
FROM docker.io/library/debian:${DEBIAN_CODENAME} as base

FROM base as builder

RUN apt -qq update && \
    apt install --no-install-recommends -qq -y build-essential

ENV QUICTLS_PREFIX "/opt/quictls"
ENV HAPROXY_PREFIX "/opt/haproxy"

FROM builder as quictls-build

COPY --chown=root:root scripts/quictls* /scripts/

ENV QUICTLS_BUILD_DIR "/tmp/quictls"
ENV QUICTLS_MAKE_INSTALL "true"
ARG QUICTLS_SOURCE

RUN /scripts/quictls-clone.sh ${QUICTLS_SOURCE} "${QUICTLS_BUILD_DIR}"
RUN /scripts/quictls-build.sh "${QUICTLS_BUILD_DIR}" "${QUICTLS_PREFIX}"
RUN ls -1 "${QUICTLS_PREFIX}/include" "${QUICTLS_PREFIX}/lib" && "${QUICTLS_PREFIX}/bin/openssl" version

FROM builder as haproxy-build

COPY --from=quictls-build /opt/quictls /opt/quictls
COPY --chown=root:root scripts/haproxy* /scripts/

ENV HAPROXY_BUILD_DIR "/tmp/haproxy"
ENV HAPROXY_MAKE_INSTALL "true"
ARG HAPROXY_SOURCE_REPO
ARG HAPROXY_SOURCE_BRANCH

RUN /scripts/haproxy-clone.sh "${HAPROXY_SOURCE_REPO}" "${HAPROXY_SOURCE_BRANCH}" "${HAPROXY_BUILD_DIR}"
RUN /scripts/haproxy-build.sh "${HAPROXY_BUILD_DIR}" "${QUICTLS_PREFIX}" "${HAPROXY_PREFIX}"
RUN "${HAPROXY_PREFIX}/usr/local/sbin/haproxy" -vv

ARG DEBIAN_CODENAME
FROM docker.io/library/debian:${DEBIAN_CODENAME}-slim

RUN apt -qq update && \
    apt -qq -y --no-install-recommends install \
      ca-certificates \
      liblua5.3-0 \
      libpcre2-8-0 \
      socat && \
    apt -qq -y --purge autoremove && \
    apt -qq -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/* /var/log/*

COPY --from=quictls-build /opt/quictls /opt/quictls
COPY --from=haproxy-build /opt/haproxy /
