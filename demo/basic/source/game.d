module game;

import re.core;
import re.util.logger;
import std.stdio;
import play;

class Game : Core {
    this() {
        super(960, 540, "basic demo");
    }

    override void initialize() {
        super.initialize();

        log.verbosity = Logger.Verbosity.Trace;
        log.info("basic demo game initialized.");

        // set up stuff and things
        scene = new PlayScene();
    }
}
