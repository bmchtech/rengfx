# rengfx

RE ENGINE FX

[![Build Status](https://travis-ci.org/xdrie/rengfx.svg?branch=master)](https://travis-ci.org/xdrie/rengfx)

lightweight, expressive, extensible game engine 

## features

### core
+ only dependency is [`raylib`](https://github.com/xdrie/raylib)
+ modular, data-driven Scene-Entity-Component architecture
+ full headless execution support, making unit tests simple
+ real time runtime debug console and inspector
+ 2d and 3d graphics support
+ multi scene layering and compositing
+ highly extensible

### physics
+ optimized SSE/AVX2 physics provided by [`nudge`](https://github.com/xdrie/nudge-d)

### audio
+ wip

## hacking

requirements:
+ `make` and a C compiler (`gcc`, `clang`)
+ `dub` and a D compiler (`dmd`, `gdc`, `ldc`)

build raylib:
```sh
git clone https://github.com/xdrie/raylib.git && cd raylib
git checkout 3.0.0_patch
cd src
make PLATFORM=PLATFORM_DESKTOP RAYLIB_LIBTYPE=SHARED RAYLIB_MODULE_RAYGUI=TRUE -j$(nproc)
# install (optional)
sudo make install PLATFORM=PLATFORM_DESKTOP RAYLIB_LIBTYPE=SHARED RAYLIB_MODULE_RAYGUI=TRUE
```

raylib needs to be in your linker search path for `raylib-d` to find. if it is installed, it should be detected automatically.

build engine:
```sh
cd src
dub test # run tests
dub build # build library
```

run demo:
```sh
cd ../demo/basic
dub run # run demo
```
