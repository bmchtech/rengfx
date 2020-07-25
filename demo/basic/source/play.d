module play;

import re;
import re.input;
import re.gfx;
import re.math;

class PlayScene : Scene2D {
    /// ball bounce direction
    private Vector2 direction = Vector2(1, 1);
    private float speed = 120;
    private Entity ball;

    override void on_start() {
        clear_color = Colors.LIGHTGRAY;

        // add ball
        ball = create_entity("ball", Vector2(20, 40));
        auto ball_spr = new Sprite(Core.content.load_texture2d("ball.png"));
        ball.add_component(new SpriteRenderer(ball_spr));

        // add text
        auto hello = create_entity("hello", Vector2(20, resolution.y - 20));
        hello.add_component(new Text(Text.default_font, "hello, world!", Text.default_size, Colors.WHITE));
    }

    override void update() {
        Core.debug_render = Input.is_key_down(Keys.KEY_TAB);

        // update direction
        if (ball.position2.x >= resolution.x) {
            direction = Vector2(-1, direction.y);
        }

        if (ball.position2.x <= 0) {
            direction = Vector2(1, direction.y);
        }

        if (ball.position2.y >= resolution.y) {
            direction = Vector2(direction.x, -1);
        }

        if (ball.position2.y <= 0) {
            direction = Vector2(direction.x, 1);
        }

        // move ball
        ball.position2 = ball.position2 + direction * speed * Time.delta_time;
    }
}
