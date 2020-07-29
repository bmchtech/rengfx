module re.ng.diag.fps_counter;

import re.core;
import re.math;
import re.ecs.component;
import re.ecs.renderable;
import std.string : format;
import re.util.interop;
static import raylib;

class FPSCounter : Component, Renderable2D {
    @property public Rectangle bounds() {
        return Rectangle(transform.position2.x, transform.position2.y, 60, 10);
    }

    void render() {
        auto fps_str = format("FPS: %s", Core.fps);
        raylib.DrawText(fps_str.c_str(), cast(int) transform.position2.x,
                cast(int) transform.position2.y, 4, raylib.Colors.RED);
    }

    void debug_render() {
    }
}
