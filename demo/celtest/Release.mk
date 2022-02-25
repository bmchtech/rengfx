BIN = binary

CONTENT_SRC := ../../content/
CONTENT_DST := .

GET_LIBPATHS := ldd $(BIN) | grep "=> /" | awk '{print $$3}'
COPY_LIB := xargs -I '{}' cp -v '{}' .

.PHONY: all content $(LIBS)
all: $(BIN) content libs

$(BIN):
	dub build -b release --root ..
	cp -v ../$(BIN) $(BIN)
	strip $(BIN)

content:
	cp -rvn $(CONTENT_SRC) $(CONTENT_DST)

# copy shared libraries
libs: $(BIN)
	$(GET_LIBPATHS) | grep "raylib" | $(COPY_LIB)

.PHONY: clean
clean:
	rm -v $(BIN)
	# remove copied content
	rm -rv $(CONTENT_DST)/content
	# remove shared libs
	rm -rv lib*
