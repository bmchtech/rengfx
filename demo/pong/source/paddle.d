module paddle;

import re;
import input;

class Paddle : Component, Updatable {
    public float speed = 20;
    private InputController controls;

    override void setup() {
        controls = entity.get_component!InputController;
    }

    void update() {
        if (controls.move.value < 0) {
            entity.position2.x -= speed * Time.delta_time;
        }

        if (controls.move.value > 0) {
            entity.position2.x += speed * Time.delta_time;
        }
    }
}
