module play;

import std.stdio;

import re;
import re.gfx;
import re.gfx.shapes.model;
import re.gfx.shapes.grid;
import re.gfx.shapes.cube;
import re.gfx.lighting.basic;
import re.gfx.effects.frag;
import re.ng.camera;
import re.math;
import re.util.orbit;
static import raylib;

import app;

/// simple 3d demo scene
class PlayScene : Scene3D {
    FragEffect shd_draw;
    PostProcessor draw_p;
    PostProcessor present_p;

    override void on_start() {
        clear_color = Colors.WHITE;

        // draw shader
        auto draw_shd_path = "shader/blossom.frag";
        if (Game.custom_drawshd_path) {
            draw_shd_path = Game.custom_drawshd_path;
        }
        shd_draw = new FragEffect(this, Core.content.load_shader(null, draw_shd_path));
        draw_p = new PostProcessor(resolution, shd_draw);
        postprocessors ~= draw_p;

        // present shader
        auto present_shd_path = "shader/present.frag";
        if (Game.custom_presentshd_path) {
            present_shd_path = Game.custom_presentshd_path;
        }
        auto shd_present = new FragEffect(this, Core.content.load_shader(null,
                present_shd_path));
        present_p = new PostProcessor(resolution, shd_present);
        postprocessors ~= present_p;
    }

    override void update() {
        super.update();

        shd_draw.update();
    }
}
