module play;

import re.core;
import re.scene;

class PlayScene : Scene {
    this() {
        // TODO: stuff
    }

    override void on_start() {
        Core.log.info("play scene started.");
    }

    override void unload() {
        Core.log.info("play scene ended.");
    }
}