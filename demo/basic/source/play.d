module play;

import re;
static import raylib;
import re.gfx.sprite;
import re.gfx.sprite_renderer;
import re.math;

class PlayScene : Scene {
    this() {
        clear_color = raylib.BLACK;
    }

    override void on_start() {
        // add ball
        auto ball = create_entity("ball", Vector2(20, 20));
        auto ball_spr = new Sprite(Core.content.load_texture2d("ball.png"));
        ball.add_component(new SpriteRenderer(ball_spr));

        Core.log.trace("play scene started.");
    }

    override void unload() {
        Core.log.trace("play scene ended.");
    }
}