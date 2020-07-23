module comp.ai;

import re;
import input;
import comp.ball;

class AiPlayer : Component, Updatable {
    private LogicController controller;
    private Ball ball;

    this(Ball ball) {
        this.ball = ball;
    }

    override void setup() {
        controller = entity.get_component!LogicController();
    }

    void update() {
        controller.zero();
        if (ball.entity.position2.x < entity.position2.x) {
            controller.move_logical.logic_value = -1;
        }
        if (ball.entity.position2.x > entity.position2.x) {
            controller.move_logical.logic_value = 1;
        }
    }
}
