PROJECT_NAME=versation

.PHONY: run clean

build/debug/$(PROJECT_NAME): versation.pas
	@ mkdir -p build/debug
	sh deps/ray4laz/fpc-wrapper.sh -gw3 -O- $< -o$@

build/release/$(PROJECT_NAME): versation.pas
	@ mkdir -p build/release
	sh deps/ray4laz/fpc-wrapper.sh -O3 $< -o$@

run: debug
	./build/debug/$(PROJECT_NAME)

clean:
	rm -r build

deps:
	git submodule update --init --recursive --depth=1
