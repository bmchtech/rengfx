module play;

import re;
static import raylib;
import re.gfx.sprite;
import re.gfx.sprite_renderer;

class PlayScene : Scene {
    this() {
        clear_color = raylib.LIGHTGRAY;
    }

    override void on_start() {
        // add ball
        auto ball = ecs.create_entity();
        auto ball_spr = new Sprite(Core.content.load_texture2d("ball.png"));
        ball.add_component(new SpriteRenderer(ball_spr));

        Core.log.info("play scene started.");
    }

    override void unload() {
        Core.log.info("play scene ended.");
    }
}