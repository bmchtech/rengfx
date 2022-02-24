module play;

import std.stdio;

import re;
import re.gfx;
import re.gfx.shapes.model;
import re.gfx.shapes.grid;
import re.gfx.shapes.cube;
import re.gfx.lighting.basic;
import re.ng.camera;
import re.math;
import re.util.orbit;
static import raylib;

import app;

/// simple 3d demo scene
class PlayScene : Scene3D {
    PostProcessor draw_p;
    PostProcessor present_p;
    int start_frame = 0;
    float start_time = 0;

    override void on_start() {
        clear_color = Colors.WHITE;

        start_frame = Time.frame_count;
        start_time = Time.total_time;

        // draw shader
        auto draw_shd_path = "shader/blossom.frag";
        if (Game.custom_drawshd_path) {
            draw_shd_path = Game.custom_drawshd_path;
        }
        auto shd_draw = Effect(Core.content.load_shader(null, draw_shd_path), Colors.WHITE);
        shd_draw.set_shader_var_imm("i_resolution", cast(float[3])[
                resolution.x, resolution.y, 1.0
            ]);
        draw_p = new PostProcessor(resolution, shd_draw);
        postprocessors ~= draw_p;

        // present shader
        auto present_shd_path = "shader/present.frag";
        if (Game.custom_presentshd_path) {
            present_shd_path = Game.custom_presentshd_path;
        }
        auto shd_present = Effect(Core.content.load_shader(null,
                present_shd_path), Colors.WHITE);
        shd_present.set_shader_var_imm("i_resolution", cast(float[3])[
                resolution.x, resolution.y, 1.0
            ]);
        present_p = new PostProcessor(resolution, shd_present);
        postprocessors ~= present_p;
    }

    override void update() {
        super.update();

        // set vars
        draw_p.effect.set_shader_var_imm("i_frame", cast(int)(Time.frame_count - start_frame));
        draw_p.effect.set_shader_var_imm("i_time", cast(float)(Time.total_time - start_time));
    }
}
