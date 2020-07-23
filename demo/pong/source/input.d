module input;

import re.ecs;
import re.input;

class InputController : Component {
    public VirtualAxis move;

    this() {
        move = new VirtualAxis();
    }

    public override void destroy() {
        move.unregister();
    }
}

class PlayerController : InputController {
    this() {
        move.nodes ~= new VirtualAxis.KeyboardKeys(Keys.KEY_LEFT, Keys.KEY_RIGHT);
    }
}

class LogicController : InputController {
    this() {
        move.nodes ~= new VirtualAxis.LogicAxis();
    }
}
