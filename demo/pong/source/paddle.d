module paddle;

import re;
import re.math;
import re.gfx;
import input;

class Paddle : Component, Updatable {
    public float speed = 80;
    private InputController controls;
    private SpriteRenderer spr_ren;

    override void setup() {
        controls = entity.get_component!InputController;
        spr_ren = entity.get_component!SpriteRenderer;
    }

    void update() {
        if (controls.move.value < 0) {
            entity.position2 = entity.position2 + Vector2(-speed * Time.delta_time, 0);
        }

        if (controls.move.value > 0) {
            entity.position2 = entity.position2 + Vector2(speed * Time.delta_time, 0);
        }

        if (entity.position2.x - spr_ren.bounds.width / 2 <= 0) {
            entity.position2 = Vector2(spr_ren.bounds.width / 2, entity.position2.y);
        }

        if (entity.position2.x + spr_ren.bounds.width / 2 >= Core.window.width) {
            entity.position2 = Vector2(Core.window.width - spr_ren.bounds.width / 2, entity.position2.y);
        }
    }
}
