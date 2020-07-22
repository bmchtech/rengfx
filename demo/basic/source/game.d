module game;
import re.core;
import std.stdio;

class Game : Core {
    this() {
        super(960, 540, "basic demo");
    }

    override void initialize() {
        super.initialize();

        // set up stuff and things

        log.info("basic demo game initialized.");
    }
}