FROM ubuntu:22.04

RUN apt update && apt install -y \
      build-essential \
      gdb \
      wget

ENV DEB_BINARY="https://gitlab.com/mangadex-pub/haproxy/-/jobs/4133055340/artifacts/raw/haproxy/haproxy_2.8-dev-b5efe79-1~mangadex+fc4f505_amd64.deb"
ENV DEB_DBGSYM="https://gitlab.com/mangadex-pub/haproxy/-/jobs/4133055340/artifacts/raw/haproxy/haproxy-dbgsym_2.8-dev-b5efe79-1~mangadex+fc4f505_amd64.deb"

RUN wget -O main.deb "$DEB_BINARY" && dpkg -i main.deb
RUN wget -O dbg.deb "$DEB_DBGSYM" && dpkg -i dbg.deb

RUN apt install -f
