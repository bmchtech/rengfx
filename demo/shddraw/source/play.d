module play;

import std.stdio;
import optional;

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
import re.util.hotreload;
import re.audio;
static import raylib;

import app;

/// simple 3d demo scene
class PlayScene : Scene3D {
    FragEffect shd_draw;
    FragEffect shd_present;
    PostProcessor draw_p;
    PostProcessor present_p;

    override void on_start() {
        clear_color = Colors.WHITE;

        // draw shader
        auto draw_shd_path = "shader/blossom.frag";
        if (Game.custom_drawshd_path) {
            draw_shd_path = Game.custom_drawshd_path;
        }
        shd_draw = new FragEffect(this, new ReloadableShader(null, draw_shd_path));
        draw_p = new PostProcessor(resolution, shd_draw);
        postprocessors ~= draw_p;

        // present shader
        auto present_shd_path = "shader/present.frag";
        if (Game.custom_presentshd_path) {
            present_shd_path = Game.custom_presentshd_path;
        }
        shd_present = new FragEffect(this, new ReloadableShader(null, present_shd_path));
        present_p = new PostProcessor(resolution, shd_present);
        postprocessors ~= present_p;

        // enable audio
        auto audio = new AudioManager();
        add_manager(audio);
        audio.play_music(Core.content.load_music("audio/50_50.mp3").front);
    }

    override void update() {
        super.update();

        shd_draw.update();
        shd_present.update();
    }
}
