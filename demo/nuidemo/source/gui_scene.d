module gui_scene;

import re;
import re.gfx;
import re.math;
import std.format;
import re.util.interop;

import gui_root;

static import raylib;
static import raygui;

class GuiScene : Scene2D {
    override void on_start() {
        clear_color = Colors.RAYWHITE;

        // add gui root
        auto ui_root = create_entity("ui_root", Vector2.zero);
        ui_root.add_component!GuiRoot();
    }

    override void update() {
        super.update();
    }

    override void render_hook() {
        // draw fps in bottom right corner
        auto ui_scale = cast(int)(Core.window.dpi_scale * Core.render_oversample_factor);
        auto font_size = 16 * ui_scale;
        raylib.DrawText(
            format("%s", Core.fps).c_str(),
            cast(int)(resolution.x - font_size - 30), cast(int)(resolution.y - font_size - 24),
            font_size, Colors.WHITE
        );
    }
}
