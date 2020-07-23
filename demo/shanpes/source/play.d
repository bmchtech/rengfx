module play;

import re;
import re.math;
import comp.square;
static import raylib;

class PlayScene : Scene {
    override void on_start() {
        clear_color = raylib.LIGHTGRAY;

        auto player = create_entity("player", Vector2(20, 20));
        player.add_component(new Square(Vector2(20, 20), raylib.BLUE));
    }
}
