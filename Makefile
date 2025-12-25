PC = fpc
CFLAGS     = -MOBJFPC deps/raylib-5.5_linux_amd64/lib/libraylib.a
CFLAGS_DEB = -O- -gw3
CFLAGS_REL = -O3

BUILD     = build
BUILD_DEB = $(BUILD)/debug
BUILD_REL = $(BUILD)/release

EXE_DEB = $(BUILD_DEB)/versation
EXE_REL = $(BUILD_REL)/versation

.PHONY: run clean

debug: $(EXE_DEB)
release: $(EXE_REL)

run: debug
	./$(EXE_DEB)

$(EXE_DEB): versation.pas
	@ mkdir -p $(BUILD_DEB)
	$(PC) $(CFLAGS) $(CFLAGS_DEB) $< -o$@

$(EXE_REL): versation.pas
	@ mkdir -p $(BUILD_REL)
	$(PC) $(CFLAGS) $(CFLAGS_REL) $< -o$@

clean:
	rm -r $(BUILD)
