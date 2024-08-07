module hud;

import re;
import re.gfx;
import re.math;
import std.format;
import re.util.interop;

static import raylib;

class HUDScene : Scene2D {
    override void on_start() {
        clear_color = Colors.BLANK;
        // set the tint of this scene's composite
        composite_mode.color = Color(255, 255, 255, 160);

        enum pad = 4;

        // auto msg = create_entity("msg", Vector2(pad, resolution.y - pad));
        // auto hello_text = msg.add_component(new Text(Text.default_font,
        //         "table.", 10, Colors.PURPLE));
        // hello_text.set_align(Text.Align.Close, Text.Align.Far);
    }

    override void render_hook() {
        // draw fps
        raylib.DrawText(format("%s", Core.fps).c_str(), 8, 8, 8, Colors.WHITE);
    }
}
