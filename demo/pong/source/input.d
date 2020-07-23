module input;

import re.ecs;
import re.input;

class InputComponent : Component {
    public VirtualAxis move;

    this() {
        move = new VirtualAxis();
        move.nodes ~= new VirtualAxis.KeyboardKeys(Keys.KEY_LEFT, Keys.KEY_RIGHT);
    }

    public override void destroy() {
        move.unregister();
    }
}