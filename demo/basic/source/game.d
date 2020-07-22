module game;

import re.core;
import std.stdio;
import play;

class Game : Core {
    this() {
        super(960, 540, "basic demo");
    }

    override void initialize() {
        super.initialize();

        // set up stuff and things
        scene = new PlayScene();

        log.info("basic demo game initialized.");
    }
}
