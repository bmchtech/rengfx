module re.ng.debugger;

import re.core;
import re.ecs.renderable;
import re.input.input;
import re.gfx;
static import raylib;

class Debugger {
    private enum padding = 12;
    private enum bg_col = Color(180, 180, 180, 180);
    private enum console_height = 16;

    public void update() {
        if (Input.is_key_pressed(Keys.KEY_GRAVE)) {
            Core.debug_render = !Core.debug_render;
        }
    }

    public void render() {
        // draw rect
        raylib.DrawRectangle(padding, Core.window.height - padding - console_height, Core.window.width - padding * 2, console_height, bg_col);
    }

    public static void default_debug_render(Renderable renderable) {
        raylib.DrawRectangleLinesEx(renderable.bounds, 1, raylib.Colors.RED);
    }
}
