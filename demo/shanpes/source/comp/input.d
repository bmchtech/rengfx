module comp.input;

import re.ecs;
import re.input;
import re.math;

abstract class InputController : Component {
    public VirtualJoystick move;
    public VirtualAxis turn;

    this() {
        move = new VirtualJoystick();
        turn = new VirtualAxis();
    }

    public override void destroy() {
        move.unregister();
    }
}

class PlayerController : InputController {
    this() {
        move.nodes ~= new VirtualJoystick.KeyboardKeys(Keys.KEY_LEFT,
                Keys.KEY_RIGHT, Keys.KEY_UP, Keys.KEY_DOWN);
        turn.nodes ~= new VirtualAxis.KeyboardKeys(Keys.KEY_E, Keys.KEY_Q);
    }
}

class LogicController : InputController {
    public VirtualJoystick.LogicJoystick logic_move;
    public VirtualAxis.LogicAxis logic_turn;

    this() {
        move.nodes ~= (logic_move = new VirtualJoystick.LogicJoystick());
        turn.nodes ~= (logic_turn = new VirtualAxis.LogicAxis());
    }

    void zero() {
        logic_move.logic_value = Vector2Zero;
        logic_turn.logic_value = 0;
    }
}
