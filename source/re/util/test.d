module re.util.test;

import re.core;

version (unittest) {
    abstract class TestGame : Core {
        this() {
            headless = true;
            super(1280, 720, string.init);
        }
    }
}
