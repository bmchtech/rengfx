module hud;

import re;
import re.gfx;
import re.math;
import re.ng.diag.fps_counter;

class HUDScene : Scene2D {
    override void on_start() {
        clear_color = Colors.BLANK;
        // set the tint of this scene's composite
        composite_mode.color = Color(255, 255, 255, 160);

        enum pad = 4;

        auto msg = create_entity("msg", Vector2(pad, resolution.y - pad));
        auto hello_text = msg.add_component(new Text(Text.default_font,
                "blocks - physics and lighting", 20, Colors.BROWN));
        hello_text.set_align(Text.Align.Close, Text.Align.Far);

        auto diag = create_entity("diag", Vector2(2, 2));
        diag.add_component!FPSCounter();
    }
}
