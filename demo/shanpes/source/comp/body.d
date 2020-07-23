module comp.body;

import re;
import re.math;
import comp.input;

class ShapeBody : Component, Updatable {
    /// movement speed
    enum move_speed = 40;
    /// turn speed
    enum turn_speed = PI / 2;
    private InputController controller;

    override void setup() {
        controller = entity.get_component!InputController();
    }

    void update() {
        entity.position2 = entity.position2 + (controller.move.value * move_speed * Time.delta_time);

        entity.transform.rotation = entity.transform.rotation + (
                controller.turn.value * turn_speed * Time.delta_time);
    }
}
