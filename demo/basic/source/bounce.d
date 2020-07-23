module bounce;

import re;
import re.input;
import re.gfx;
static import raylib;
import re.math;

class BounceScene : Scene {
    /// ball bounce direction
    private Vector2 direction = Vector2(1, 1);
    private float speed = 240;
    private Entity ball;

    override void on_start() {
        clear_color = raylib.BLACK;

        // add ball
        ball = create_entity("ball", Vector2(20, 40));
        auto ball_spr = new Sprite(Core.content.load_texture2d("ball.png"));
        ball.add_component(new SpriteRenderer(ball_spr));

        // add text
        auto hello = create_entity("hello", Vector2(20, Core.window.height - 20));
        hello.add_component(new Text(Text.default_font, "hello, world!", Text.default_size, raylib.WHITE));
    }

    override void update() {
        Core.debug_render = Input.is_key_down(Keys.KEY_TAB);

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
        ball.position2 = ball.position2 + direction * speed * Time.delta_time;
    }
}
