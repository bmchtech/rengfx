module comp.body;

import re;
import re.math;
import comp.input;
import re.phys.rigid3d;

class Character : Component, Updatable {
    /// movement speed
    enum move_speed = 40;

    private InputController controller;
    private DynamicBody bod;

    override void setup() {
        controller = entity.get_component!InputController();
        bod = entity.get_component!DynamicBody();
    }

    override void update() {
        if (controller.jump.is_pressed) {
            // jump
            bod.velocity.y += 10f;
        }
    }
}
