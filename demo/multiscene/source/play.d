module play;

import re;
import re.gfx;
import re.gfx.shapes.rect;
import re.ng.camera;
import re.math;
import re.phys.kin2d;

static import raylib;

class PlayScene : Scene2D {
    override void on_start() {
        resolution = Vector2(100, 100);
        output_rect = Rectangle(
            0, 0,
            Core.window.screen_width / 2,
            Core.window.screen_height
        );

        auto bg_tween = Tweener.tween(clear_color, Colors.DARKGRAY,
            Colors.LIGHTGRAY, 2, &Ease.QuadIn);
        bg_tween.start();

        auto box1 = create_entity("box1", Vector2(20, 20));
        box1.add_component(new ColorRect(Vector2(8, 8), Colors.BLUE));
        auto box1_body = box1.add_component!KinBody2D();
        box1_body.angular_accel = 0.1;

        auto box2 = create_entity("box2", Vector2(40, 20));
        box2.add_component(new ColorRect(Vector2(8, 8), Colors.RED));
        auto box2_body = box2.add_component!KinBody2D();
        box2_body.angular_accel = -0.07;

        // follow the first box
        cam.entity.add_component(new CameraFollow2D(box1, 0.05));
    }
}
