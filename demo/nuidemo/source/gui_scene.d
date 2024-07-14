module gui_scene;

import re;
import re.gfx;
import re.math;
import std.format;
import re.util.interop;

import gui_root;

static import raylib;
static import raygui;

class GuiScene : SceneBasic {
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
        // raylib.DrawText(format("%s", Core.fps).c_str(), 8, 8, 8, Colors.BLACK);
        raylib.DrawText(format("%s", Core.fps).c_str(), cast(int)(resolution.x - 30), cast(int)(resolution.y - 24), 16, Colors.WHITE);
    }
}
