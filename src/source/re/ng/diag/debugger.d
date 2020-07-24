module re.ng.diag.debugger;

import re.core;
import re.ecs.renderable;
import re.input.input;
import re.math;
import re.gfx;
import re.ng.diag.console;
import re.ng.diag.inspector;
static import raylib;
static import raygui;

/// a robust overlay debugging tool
class Debugger {
    public enum screen_padding = 12;
    private enum bg_col = Color(180, 180, 180, 180);

    /// inspector panel
    public static Inspector inspector;

    /// debug console
    public static Console console;

    /// sets up debugger
    this() {
        inspector = new Inspector();
        console = new Console();
    }

    public void update() {
        if (Input.is_key_pressed(console.key)) {
            Core.debug_render = !Core.debug_render;
            console.open = !console.open;
        }

        if (inspector.open)
            inspector.update();
        if (console.open)
            console.update();
    }

    public void render() {
        if (inspector.open)
            inspector.render();
        if (console.open)
            console.render();
    }

    public static void default_debug_render(Renderable renderable) {
        raylib.DrawRectangleLinesEx(renderable.bounds, 1, raylib.Colors.RED);
    }
}
