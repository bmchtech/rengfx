module play;

import re;
import re.gfx;
import re.math;
static import raylib;
import input;
import comp.paddle;
import comp.ball;

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
        player.add_component!Paddle();

        auto alice = create_entity("alice", Vector2(Core.window.width / 2, padding));
        alice.add_component(new SpriteRenderer(paddle_sprite));
        alice.add_component!LogicController();
        player.add_component!Paddle();

        auto ball = create_entity("ball", Vector2(Core.window.width / 2, Core.window.height / 2));
        ball.add_component(new SpriteRenderer(new Sprite(ball_tex)));
        ball.add_component!Ball();

        auto pong = create_entity("pong", Vector2(padding, (Core.window.height / 2) - padding));
        auto pong_text = pong.add_component(new Text(Text.default_font, "pong", Text.default_size, raylib.WHITE));
        pong_text.set_align(Text.Align.Close, Text.Align.Center);
    }
}
