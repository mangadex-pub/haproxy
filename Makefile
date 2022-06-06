all: deps haproxy

deps: deps/lua deps/pcre2 deps/quictls

deps/lua:
	$(MAKE) -C "deps/lua"

deps/pcre2:
	$(MAKE) -C "deps/pcre2"

deps/quictls:
	$(MAKE) -C "deps/quictls"

haproxy:
	$(MAKE) -C "haproxy"

.PHONY: deps/* haproxy
