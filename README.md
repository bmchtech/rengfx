# rengfx

RE ENGINE FX

lightweight, expressive, extensible game engine 

## features
+ only dependency is [`raylib`](https://github.com/xdrie/raylib)
+ Scene-Entity-Component architecture
+ 2d and 3d graphics support
+ highly extensible

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
```

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
