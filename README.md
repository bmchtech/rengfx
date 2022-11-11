# rengfx

RE ENGINE FX

[![DUB Package](https://img.shields.io/dub/v/reng.svg)](https://code.dlang.org/packages/reng)

lightweight, expressive, extensible game engine 

![blocks demo gif](https://raw.githubusercontent.com/wiki/xdrie/rengfx/img/rec-2020-07-30_17.17.12.gif)

![table demo gif](https://raw.githubusercontent.com/wiki/xdrie/rengfx/img/rengfx_fox.gif)

## features

+ only library dependency is [`raylib`](https://github.com/xdrie/raylib)
+ engine features
  + combined, mixable 2d and 3d graphics support
  + cross platform, system-independent graphics
  + composable, modular game components and rendering
  + virtual input for transparent rebinding and cross platform input
  + vector/matrix math hidden behind nice abstractions
  + vr support
+ modular, data-driven Scene-Entity-Component architecture
  + full headless execution support, making unit tests simple
  + emphasis on simplicity and readability, avoidance of unnecessary abstraction
  + multi scene layering and compositing
  + highly extensible with custom components and logic
  + everything can be overrided or extended
+ fluent debugging
  + real time runtime debug console and inspector
+ simple and powerful glsl shaders
  + bulit-in shaders for stylized lighting and postprocessing
  + streamlined shaders api for custom glsl shaders
+ wip
  + wip: physics support and integration
  + wip: tilemaps with tiled

## documentation
+ full documentation: [api docs](https://redthing1.github.io/rengfx/)
+ demo projects: [demos](demo/)
+ notes and tips: [doc](doc/)

## hacking

requirements:
+ `make` and a C compiler (`gcc`, `clang`)
+ `dub` and a D compiler (`dmd`, `gdc`, `ldc`)

rengfx depends on raylib (via [dray](https://github.com/xdrie/dray) bindings).
by default, `dray` will run a pre-generate script that automatically builds `raylib`.

build engine:
```sh
dub test # run tests
dub build # build library
```

open docs locally:
```sh
dub run -b ddox
```

run demo:
```sh
cd demo/<name>
dub run # run demo
```

## license

copyright © 2020-2022, redthing1.

available to use under the [LGPL v3.0](LICENSE).

libraries:
+ [raylib](https://github.com/raysan5/raylib/blob/be7f717a24e72e0bc84389491a063de65c106048/LICENSE), Zlib license
