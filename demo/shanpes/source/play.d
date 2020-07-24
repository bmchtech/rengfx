module play;

import re;
import re.gfx;
import re.math;
import comp.input;
import comp.square;
import comp.body;
import comp.ai;
static import raylib;

class PlayScene : Scene {
    override void on_start() {
        clear_color = Colors.LIGHTGRAY;

        auto player = create_entity("player", Vector2(20, 20));
        player.add_component(new Square(Vector2(8, 8), Colors.BLUE));
        player.add_component!PlayerController();
        player.add_component!ShapeBody();

        auto turret = create_entity("turret", Vector2(80, 80));
        turret.add_component(new Square(Vector2(8, 8), Colors.DARKGRAY));
        turret.add_component!LogicController();
        turret.add_component!ShapeBody();
        turret.add_component!AiPlayer();
    }
}
