module bounce;

import re;
import re.gfx;
static import raylib;
import re.math;

class BounceScene : Scene {
    override void on_start() {
        clear_color = raylib.BLACK;

        // add ball
        auto ball = create_entity("ball", Vector2(20, 20));
        auto ball_spr = new Sprite(Core.content.load_texture2d("ball.png"));
        ball.add_component(new SpriteRenderer(ball_spr));
    }
}
