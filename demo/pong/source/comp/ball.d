module comp.ball;

import re;
import re.math;
import re.gfx;

class Ball : Component, Updatable {
    private float speed = 160;
    private Vector2 direction = Vector2(1, 1);
    private SpriteRenderer spr_ren;

    override void setup() {
        spr_ren = entity.get_component!SpriteRenderer;
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
            direction = Vector2(direction.x, -1);
        }

        if (entity.position2.y - spr_ren.bounds.height / 2 <= 0) {
            direction = Vector2(direction.x, 1);
        }

        entity.position2 = entity.position2 + (direction * speed * Time.delta_time);
    }
}
