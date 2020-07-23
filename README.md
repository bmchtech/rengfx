# rengfx

RE ENGINE FX

lightweight, expressive, extensible game engine 

## features
+ only dependency is `raylib`
+ Scene-Entity-Component architecture
+ 2d and 3d graphics support
+ highly extensible

## hacking

requirements:
+ `dub` and a D compiler (`dmd`, `gdc`, `ldc`)

build:
```sh
cd src
dub test # run tests
dub build # build library
cd ../demo/basic
dub run # run demo
```
