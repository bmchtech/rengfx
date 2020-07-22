module play;

import re;
static import raylib;

class PlayScene : Scene {
    this() {
        clearColor = raylib.LIGHTGRAY;
    }

    override void on_start() {
        Core.log.info("play scene started.");
    }

    override void unload() {
        Core.log.info("play scene ended.");
    }
}