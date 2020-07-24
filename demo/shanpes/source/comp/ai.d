module comp.ai;

import re.ecs;
import comp.input;

class AiPlayer : Component, Updatable {
    private LogicController controller;

    override void setup() {
        controller = entity.get_component!LogicController();
    }

    void update() {
        controller.zero();

        controller.logic_turn.logic_value = 1;
    }
}
