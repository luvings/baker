CC      ?= gcc
CFLAGS  ?= -O2 -DTARGET_ROCKCHIP_RECOVERY=true -DUSE_OPENSSL
LDFLAGS ?= -lcrypto
PREFIX  ?= usr/local

TARGETS = mkbootimg unmkbootimg rkafpack rkcrc rkdump rkflash rkunpack
DEPS    = Makefile

all: $(TARGETS)

%: %.c $(COMMON) $(DEPS)
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

install: $(TARGETS)
	install -d -m 0755 $(DESTDIR)/$(PREFIX)/bin
	install -m 0755 $(TARGETS) $(DESTDIR)/$(PREFIX)/bin

.PHONY: clean uninstall

clean:
	rm -f $(TARGETS)

uninstall:
	cd $(DESTDIR)/$(PREFIX)/bin && rm -f $(TARGETS)
