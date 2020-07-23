module play;

import re;
import re.gfx;
import re.math;
static import raylib;
import input;

class PlayScene : Scene {
    override void on_start() {
        clear_color = raylib.BLACK;

        auto ball_tex = Core.content.load_texture2d("ball.png");
        auto paddle_tex = Core.content.load_texture2d("paddle.png");

        auto padding = 20;

        auto paddle_sprite = new Sprite(paddle_tex);

        auto player = create_entity("player", Vector2(Core.window.width / 2, Core.window.height - padding));
        player.add_component(new SpriteRenderer(paddle_sprite));
        player.add_component!PlayerController();

        auto alice = create_entity("alice", Vector2(Core.window.width / 2, padding));
        alice.add_component(new SpriteRenderer(paddle_sprite));
        alice.add_component!LogicController();

        auto ball = create_entity("ball", Vector2(Core.window.width / 2, Core.window.height / 2));
        ball.add_component(new SpriteRenderer(new Sprite(ball_tex)));
    }
}
