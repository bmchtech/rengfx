module comp.ball;

import re;
import re.math;
import re.gfx;
import std.random;

class Ball : Component, Updatable {
    private float speed = 160;
    private Vector2 direction;
    private SpriteRenderer spr_ren;

    override void setup() {
        spr_ren = entity.get_component!SpriteRenderer;
        respawn();
    }

    void respawn() {
        auto x_dir = [-1, 1].choice(Rng.rng);
        auto y_dir = [-1, 1].choice(Rng.rng);
        direction = Vector2(x_dir, y_dir);

        entity.position2 = Vector2(Core.window.width / 2, Core.window.height / 2);
    }

    void update() {
        // update direction
        if (entity.position2.x + spr_ren.bounds.width / 2 >= Core.window.width) {
            direction = Vector2(-1, direction.y);
        }

        if (entity.position2.x - spr_ren.bounds.width / 2 <= 0) {
            direction = Vector2(1, direction.y);
        }

        if (entity.position2.y + spr_ren.bounds.height / 2 >= Core.window.height) {
            // hit the bottom, ENEMY SCORE
            respawn();
        }

        if (entity.position2.y - spr_ren.bounds.height / 2 <= 0) {
            // hit the top, PLAYER SCORE
            respawn();
        }

        entity.position2 = entity.position2 + (direction * speed * Time.delta_time);
    }
}
