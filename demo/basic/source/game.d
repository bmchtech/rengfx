module game;
import re.core;
import std.stdio;

class Game : Core {
    override void initialize() {
        writeln("custom game initialized.");
    }
}