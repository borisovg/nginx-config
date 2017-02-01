WS_FILES = Makefile README.md            \
           $(shell find bin/ -type f) \
           $(shell find templates/ -type f)

all: whitespace rsync

rsync:
	./local/rsync.sh

whitespace: local/.ws_done
	@touch $^

local/.ws_done: $(WS_FILES)
	for f in $?; do sed -r 's/\s+$$//' $$f > $$f.ws; cat $$f.ws > $$f; rm $$f.ws; done

.PHONY: rsync whitespace
