module play;

import re;
import re.gfx;
import re.math;
import comp.input;
import comp.square;
import comp.body;
static import raylib;

class PlayScene : Scene {
    override void on_start() {
        clear_color = Colors.LIGHTGRAY;

        auto player = create_entity("player", Vector2(20, 20));
        player.add_component(new Square(Vector2(10, 10), Colors.BLUE));
        player.add_component!PlayerController();
        player.add_component!ShapeBody();
    }
}
