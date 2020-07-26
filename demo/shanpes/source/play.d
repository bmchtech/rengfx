module play;

import re;
import re.gfx;
import re.gfx.shapes.rect;
import re.ng.camera;
import re.math;
import comp.input;
import comp.body;
import comp.ai;
static import raylib;

class PlayScene : Scene2D {
    override void on_start() {
        auto bg_tween = Tweener.tween(clear_color, Colors.DARKGRAY,
                Colors.LIGHTGRAY, 2, &Ease.QuadIn);
        bg_tween.start();

        auto player = create_entity("player", Vector2(20, 20));
        player.add_component(new ColorRect(Vector2(8, 8), Colors.BLUE));
        player.add_component!PlayerController();
        player.add_component!ShapeBody();

        // follow the player
        cam.entity.add_component(new CameraFollow2D(player, 0.05));

        auto turret = create_entity("turret", Vector2(80, 80));
        turret.add_component(new ColorRect(Vector2(8, 8), Colors.DARKGRAY));
        turret.add_component!LogicController();
        turret.add_component!ShapeBody();
        turret.add_component!AiPlayer();

        // add some tweens
        auto turret_tween_left = Tweener.tween(turret.position.x, 80, 20, 4, &Ease.QuadInOut);
        auto turret_tween_up = Tweener.tween(turret.position, Vector3(20, 80, 0), Vector3(60, 20, 0), 4, &Ease.SineOut);
        bg_tween.add_chain(turret_tween_left);
        turret_tween_left.add_chain(turret_tween_up);
    }
}
