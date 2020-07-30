module comp.input;

import re.ecs;
import re.input;
import re.math;

abstract class InputController : Component {
    public VirtualJoystick move;
    public VirtualButton jump;

    this() {
        move = new VirtualJoystick();
        jump = new VirtualButton();
    }

    public override void destroy() {
        move.unregister();
    }
}

class PlayerController : InputController {
    this() {
        move.nodes ~= new VirtualJoystick.KeyboardKeys(Keys.KEY_LEFT,
                Keys.KEY_RIGHT, Keys.KEY_UP, Keys.KEY_DOWN);
        jump.nodes ~= new VirtualButton.KeyboardKey(Keys.KEY_SPACE);
    }
}
