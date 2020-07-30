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

        auto desc = create_entity("desc", Vector2(pad, resolution.y - pad));
        auto hello_text = desc.add_component(new Text(Text.default_font,
                "blocks - physics and lighting", 30, Colors.BROWN));
        hello_text.set_align(Text.Align.Close, Text.Align.Far);

        auto diag = create_entity("diag", Vector2(2, 2));
        diag.add_component!FPSCounter();

        auto instr = create_entity("instr", Vector2(resolution.x - pad * 4, pad * 4));
        auto instr_text = instr.add_component(new Text(Text.default_font,
                "-- Controls --\nSPACE - jump\nWASD - move\nARROW - turn\n" ~ "SCROLL - zoom\nRMB - orbit",
                20, Colors.BROWN));
        instr_text.set_align(Text.Align.Far, Text.Align.Close);
    }
}
