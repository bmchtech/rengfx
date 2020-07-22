module game;
import re.core;
import std.stdio;

class Game : Core {
    override void initialize() {
        super.initialize();
        
        log.info("custom game initialized.");
    }
}