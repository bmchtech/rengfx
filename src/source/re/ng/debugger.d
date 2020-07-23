module re.ng.debugger;

import re.core;
import re.ecs.renderable;
import re.input.input;
static import raylib;

class Debugger {
    public void update() {
        if (Input.is_key_pressed(Keys.KEY_GRAVE)) {
            Core.debug_render = !Core.debug_render;
        }
    }

    public void render() {

    }

    public static void default_debug_render(Renderable renderable) {
        raylib.DrawRectangleLinesEx(renderable.bounds, 1, raylib.RED);
    }
}
