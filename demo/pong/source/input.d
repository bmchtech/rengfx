module input;

import re.ecs;
import re.input;

class InputComponent : Component {
    public VirtualAxis move;

    this() {
        move = new VirtualAxis();
        move.nodes ~= VirtualAxis.KeyboardKeys(Keys.KEY_LEFT, Keys.KEY_RIGHT);
    }
}