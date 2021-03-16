# rengfx

RE ENGINE FX

[![DUB Package](https://img.shields.io/dub/v/reng.svg)](https://code.dlang.org/packages/reng)

lightweight, expressive, extensible game engine 

![blocks demo gif](https://raw.githubusercontent.com/wiki/xdrie/rengfx/img/rec-2020-07-30_17.17.12.gif)

![table demo gif](https://raw.githubusercontent.com/wiki/xdrie/rengfx/img/rengfx_fox.gif)

[demo binary (v0.3.3) (win/linux)](https://github.com/xdrie/rengfx/releases/tag/v0.3.3)

## features

+ only library dependency is [`raylib`](https://github.com/xdrie/raylib)
+ modular, data-driven Scene-Entity-Component architecture
+ full headless execution support, making unit tests simple
+ real time runtime debug console and inspector
+ 2d and 3d graphics support
+ multi scene layering and compositing
+ integration with physics engines (`nudge`, `dmech`)
+ bulit-in shaders for stylized lighting and postprocessing
+ highly extensible
+ wip

## documentation
+ see [doc](doc/) for some small notes.
+ see [api docs](https://xdrie.github.io/rengfx/) for full api documentation

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

available to use under the [LGPL v3.0](LICENSE)

libraries:
+ [raylib](https://github.com/raysan5/raylib/blob/be7f717a24e72e0bc84389491a063de65c106048/LICENSE), Zlib license
+ [dmech](https://github.com/gecko0307/dmech/blob/8a93124fe5a57995e7b6820d5fef697e1e537dad/COPYING), Boost license
