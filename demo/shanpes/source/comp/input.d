module comp.input;

import re.ecs;
import re.input;

abstract class InputController : Component {
    public VirtualJoystick move;

    this() {
        move = new VirtualJoystick();
    }

    public override void destroy() {
        move.unregister();
    }
}

class PlayerController : InputController {
    this() {
        move.nodes ~= new VirtualJoystick.KeyboardKeys(Keys.KEY_LEFT,
                Keys.KEY_RIGHT, Keys.KEY_UP, Keys.KEY_DOWN);
    }
}
