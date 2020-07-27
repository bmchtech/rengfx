module comp.body;

import re;
import re.math;
import comp.input;
import re.phys.kin2d;

class ShapeBody : KinBody2D {
    /// movement speed
    enum move_speed = 40;
    /// turn speed
    enum turn_speed = PI / 2;
    private InputController controller;

    override void setup() {
        controller = entity.get_component!InputController();

        drag = Vector2(move_speed / 4, move_speed / 4);
        max_velocity = Vector2(move_speed, move_speed);
    }

    override void update() {
        super.update();

        velocity = velocity + (controller.move.value * move_speed * Time.delta_time);
        angular_velocity = angular_velocity + (controller.turn.value * turn_speed * Time.delta_time);
    }
}
