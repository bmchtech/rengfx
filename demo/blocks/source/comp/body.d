module comp.body;

import re;
import re.math;
import comp.input;
import re.phys.rigid3d;
static import raymath;

class Character : Component, Updatable {
    /// movement speed
    enum move_speed = 20;

    private InputController controller;
    private DynamicBody bod;

    override void setup() {
        controller = entity.get_component!InputController();
        bod = entity.get_component!DynamicBody();

        bod.max_speed  = move_speed;
    }

    override void update() {
        if (controller.jump.is_pressed) {
            // jump
            bod.apply_impulse(Vector3(0, bod.mass * 4, 0), Vector3Zero);
        }

        if (raymath.Vector2LengthSqr(controller.move.value) > 0) {
            bod.apply_impulse(Vector3(controller.move.value.x * move_speed, 0,
                    controller.move.value.y * move_speed), Vector3Zero);
        }
    }
}
