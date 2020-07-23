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
        move.nodes ~= new VirtualAxis.KeyboardKeys(Keys.KEY_RIGHT, Keys.KEY_LEFT);
    }
}

class LogicController : InputController {
    this() {
        move.nodes ~= new VirtualAxis.LogicAxis();
    }
}
