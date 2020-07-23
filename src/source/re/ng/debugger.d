module re.ng.debugger;

import re.core;
import re.input.input;

class Debugger {
    public void update() {
        if (Input.is_key_pressed(Keys.KEY_GRAVE)) {
            Core.debug_render = !Core.debug_render;
        }
    }

    public void render() {

    }
}
