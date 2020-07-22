module bounce;

import re;
import re.gfx;
static import raylib;
import re.math;

class BounceScene : Scene {
    /// ball bounce direction
    private Vector2 direction = Vector2(1, 1);
    private float speed = 10;
    private Entity ball;

    override void on_start() {
        clear_color = raylib.BLACK;

        // add ball
        ball = create_entity("ball", Vector2(20, 40));
        auto ball_spr = new Sprite(Core.content.load_texture2d("ball.png"));
        ball.add_component(new SpriteRenderer(ball_spr));
    }

    override void update() {
        // update direction
        if (ball.position2.x >= Core.window.width) {
            direction = Vector2(-1, direction.y);
        }

        if (ball.position2.x <= 0) {
            direction = Vector2(1, direction.y);
        }

        if (ball.position2.y >= Core.window.height) {
            direction = Vector2(direction.x, -1);
        }

        if (ball.position2.y <= 0) {
            direction = Vector2(direction.x, 1);
        }

        // move ball
        ball.position2 = ball.position2 + direction * speed;
    }
}
