module comp.ball;

import re;
import re.math;
import re.gfx;
import std.random;
import comp.score;
import comp.paddle;
import std.math;

class Ball : Component, Updatable {
    mixin Reflect;
    
    private enum base_speed = 160;
    private float speed = base_speed;
    private float speed_up = 20;
    private Vector2 direction;
    private SpriteRenderer spr_ren;
    private Paddle[] paddles;

    override void setup() {
        spr_ren = entity.get_component!SpriteRenderer;
        respawn();
    }

    void respawn() {
        auto x_dir = [-1, 1].choice(Rng.rng);
        auto y_dir = [-1, 1].choice(Rng.rng);
        direction = Vector2(x_dir, y_dir);
        speed = base_speed;

        entity.position2 = Vector2(Core.window.width / 2, Core.window.height / 2);
    }

    void bounce_on(Paddle paddle) {
        paddles ~= paddle;
    }

    void update() {
        // update direction
        if (entity.position2.x + spr_ren.bounds.width / 2 >= Core.window.width) {
            direction = Vector2(-1, direction.y);
        }

        if (entity.position2.x - spr_ren.bounds.width / 2 <= 0) {
            direction = Vector2(1, direction.y);
        }

        foreach (paddle; paddles) {
            // check if within paddle Y
            if (abs(entity.position2.y - paddle.entity.position2.y) < 5) {
                // check paddle X
                if (abs(entity.position2.x - paddle.entity.position2.x) < 60) {
                    direction = Vector2(direction.x, -direction.y);
                }
            }
        }

        if (entity.position2.y + spr_ren.bounds.height / 2 >= Core.window.height) {
            // hit the bottom, ENEMY SCORE
            Core.scene.get_entity("score").get_component!Scoreboard().add_point_enemy();
            respawn();
        }

        if (entity.position2.y - spr_ren.bounds.height / 2 <= 0) {
            // hit the top, PLAYER SCORE
            Core.scene.get_entity("score").get_component!Scoreboard().add_point_player();
            respawn();
        }

        entity.position2 = entity.position2 + (direction * speed * Time.delta_time);

        // increase speed
        speed += Time.delta_time * speed_up;
    }
}
