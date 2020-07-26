module play;

import re;
import re.gfx;
import re.gfx.shapes.rect;
import re.math;
import comp.input;
import comp.body;
import comp.ai;
static import raylib;

class PlayScene : Scene2D {
    override void on_start() {
        Tweener.tween(clear_color, Colors.DARKGRAY, Colors.LIGHTGRAY, 2, &Ease.QuadIn);

        auto player = create_entity("player", Vector2(20, 20));
        player.add_component(new ColorRect(Vector2(8, 8), Colors.BLUE));
        player.add_component!PlayerController();
        player.add_component!ShapeBody();

        auto turret = create_entity("turret", Vector2(80, 80));
        turret.add_component(new ColorRect(Vector2(8, 8), Colors.DARKGRAY));
        turret.add_component!LogicController();
        turret.add_component!ShapeBody();
        turret.add_component!AiPlayer();

        Tweener.tween(turret.position.x, 80, 20, 4, &Ease.QuadIn, 2);
    }
}
