module re.util.test;

import re.core;
import re.ng.scene;

version (unittest) {
    class TestGame : Core {
        this() {
            headless = true;
            super(1280, 720, string.init);
        }

        override void initialize() {
            // nothing to do here
        }
    }

    public struct TestGameRunner {
        TestGame game;
        Scene scene;
    }

    public static TestGameRunner test_scene(Scene scene) {
        auto game = new TestGame();
        game.load_scenes([scene]);
        return TestGameRunner(game, scene);
    }
}
