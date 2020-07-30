module comp.body;

import re;
import re.math;
import comp.input;
import re.phys.rigid3d;
static import raymath;

class Character : Component, Updatable {
    /// movement speed
    enum move_speed = 20;
    /// turning speed
    enum turn_speed = 10;

    private InputController controller;
    private DynamicBody bod;
    private PhysicsManager phys;

    override void setup() {
        controller = entity.get_component!InputController();
        bod = entity.get_component!DynamicBody();
        phys = entity.scene.get_manager!PhysicsManager().get;

        bod.max_speed = move_speed;
    }

    override void update() {
        // check if on ground
        auto rc = phys.raycast_from(bod, Vector3(0, -1, 0), Vector3(0, -1, 0), 1);
        if (!rc.isNull) {
            // jump
            if (controller.jump.is_pressed) {
                bod.apply_impulse(Vector3(0, bod.mass * 16, 0), Vector3Zero);
            }
        }

        // movement
        if (raymath.Vector2LengthSqr(controller.move.value) > 0) {
            bod.apply_impulse(Vector3(controller.move.value.x * move_speed, 0,
                    controller.move.value.y * move_speed), Vector3Zero);
        }

        // turning
        if (raymath.Vector2LengthSqr(controller.turn.value) > 0) {
            bod.apply_torque(Vector3(controller.turn.value.y * turn_speed * bod.mass,
                    0, -controller.turn.value.x * turn_speed * bod.mass));
        }
    }
}
