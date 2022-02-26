/** 2d renderable fps counter */

module re.ng.diag.fps_counter;

import std.format;

import re.core;
import re.math;
import re.ecs.component;
import re.ecs.renderable;
import re.gfx.raytypes;
import re.util.interop;
static import raylib;

class FPSCounter : Component, Renderable2D {
    int font_size;
    Color color;

    this(int font_size, Color color = Colors.WHITE) {
        this.font_size = font_size;
        this.color = color;
    }

    @property public Rectangle bounds() {
        return Rectangle(transform.position2.x, transform.position2.y, 60, 10);
    }

    void render() {
        auto fps_str = format("%s", Core.fps);
        raylib.DrawText(fps_str.c_str(), cast(int) transform.position2.x,
            cast(int) transform.position2.y, font_size, color);
    }

    void debug_render() {
    }
}
