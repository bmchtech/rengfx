# rengfx

RE ENGINE FX

[![Build Status](https://travis-ci.org/xdrie/rengfx.svg?branch=master)](https://travis-ci.org/xdrie/rengfx)

lightweight, expressive, extensible game engine 

## features

+ only library dependency is [`raylib`](https://github.com/xdrie/raylib)
+ modular, data-driven Scene-Entity-Component architecture
+ full headless execution support, making unit tests simple
+ real time runtime debug console and inspector
+ 2d and 3d graphics support
+ multi scene layering and compositing
+ highly extensible
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

raylib needs to be in your linker search path for `dray` to find. if it is installed, it should be detected automatically.

build engine:
```sh
cd src
dub test # run tests
dub build # build library
```

run demo:
```sh
cd ../demo/<name>
dub run # run demo
```

## license

licensed under LGPL v2.1

libraries:
+ [raylib](https://github.com/raysan5/raylib), Zlib license
