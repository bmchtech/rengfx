module gui_scene;

import re;
import re.gfx;
import re.math;
import std.format;
import re.util.interop;
import re.ng.diag.console;

import gui_root;

static import raylib;
static import raygui;

class GuiScene : Scene2D {
    size_t yoop_counter = 0;

    override void on_start() {
        clear_color = Colors.RAYWHITE;
        viewports[0].sync_maximized = true;

        // add gui root
        auto ui_root = create_entity("ui_root", Vector2.zero);
        ui_root.add_component!GuiRoot();

        // set up console commands
        yoop_counter = 0;
        Core.inspector_overlay.console.add_command(ConsoleCommand("yoop", &yoop, "yoop yoop yoop"));
    }

    override void on_unload() {
        // reset the console
        Core.inspector_overlay.console.reset();
    }

    void yoop(string[] args) {
        Core.log.info("yoop %s", yoop_counter);
        yoop_counter++;
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
