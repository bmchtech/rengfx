module paddle;

import re;
import re.math;
import input;

class Paddle : Component, Updatable {
    public float speed = 80;
    private InputController controls;

    override void setup() {
        controls = entity.get_component!InputController;
    }

    void update() {
        if (controls.move.value < 0) {
            entity.position2 = entity.position2 + Vector2(-speed * Time.delta_time, 0);
        }

        if (controls.move.value > 0) {
            entity.position2 = entity.position2 + Vector2(speed * Time.delta_time, 0);
        }
    }
}
