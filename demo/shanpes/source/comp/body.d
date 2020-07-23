module comp.body;

import re;
import re.math;
import comp.input;

class ShapeBody : Component, Updatable {
    /// movement speed
    enum speed = 40;
    private InputController controller;

    override void setup() {
        controller = entity.get_component!InputController();
    }

    void update() {
        entity.position2 = entity.position2 + (controller.move.value * speed * Time.delta_time);
    }
}
