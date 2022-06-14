all: deps haproxy

deps: deps/lua deps/pcre2 deps/quictls deps/vtest

deps/lua:
	$(MAKE) -C "deps/lua"

deps/pcre2:
	$(MAKE) -C "deps/pcre2"

deps/quictls:
	$(MAKE) -C "deps/quictls"

deps/vtest:
	$(MAKE) -C "deps/vtest"

haproxy:
	$(MAKE) -C "haproxy"

clean:
	$(MAKE) -C "deps/lua" clean
	$(MAKE) -C "deps/pcre2" clean
	$(MAKE) -C "deps/quictls" clean
	$(MAKE) -C "deps/vtest" clean
	$(MAKE) -C "haproxy" clean

.PHONY: deps/* haproxy
