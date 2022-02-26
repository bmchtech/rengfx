module hud;

import re;
import re.gfx;
import re.math;

class HUDScene : Scene2D {
    override void on_start() {
        clear_color = Colors.BLANK;
        // set the tint of this scene's composite
        composite_mode.color = Color(255, 255, 255, 160);

        enum pad = 4;

        auto msg = create_entity("msg", Vector2(pad, resolution.y - pad));
        auto hello_text = msg.add_component(new Text(Text.default_font,
                "gltf anim", 40, Colors.PURPLE));
        hello_text.set_align(Text.Align.Close, Text.Align.Far);
    }
}
