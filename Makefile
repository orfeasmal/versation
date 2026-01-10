PROJECT_NAME = versation

PC = fpc
CFLAGS         = -MOBJFPC
CFLAGS_LINUX   = -Xrdeps/raylib-5.5_linux_amd64/lib/
CFLAGS_WINDOWS = -Twin64 -Xrdeps/raylib-5.5_win64_mingw-w64/lib/

CFLAGS_DEB = -O- -gw3
CFLAGS_REL = -O3

BUILD     = build
BUILD_DEB = $(BUILD)/debug
BUILD_REL = $(BUILD)/release

EXE_DEB = $(BUILD_DEB)/$(PROJECT_NAME)
EXE_REL = $(BUILD_REL)/$(PROJECT_NAME)

BUILD_WIN_REL = $(BUILD)/windows/release
EXE_WIN_REL = $(BUILD_WIN_REL)/$(PROJECT_NAME)

SRC = src/*.pas

.PHONY: run clean

debug: $(EXE_DEB)
release: $(EXE_REL)

run: debug
	./$(EXE_DEB)

$(EXE_DEB): $(SRC)
	@ mkdir -p $(BUILD_DEB)
	$(PC) $(CFLAGS) $(CFLAGS_LINUX) $(CFLAGS_DEB) src/$(PROJECT_NAME).pas -o$@

$(EXE_REL): $(SRC)
	@ mkdir -p $(BUILD_REL)
	$(PC) $(CFLAGS) $(CFLAGS_LINUX) $(CFLAGS_REL) src/$(PROJECT_NAME).pas -o$@

windows: $(EXE_WIN_REL)
	
$(EXE_WIN_REL): $(SRC)
	@ mkdir -p $(BUILD_WIN_REL)
	$(PC) $(CFLAGS) $(CFLAGS_WINDOWS) $(CFLAGS_REL) src/$(PROJECT_NAME).pas -o$@

clean:
	rm -r $(BUILD)
