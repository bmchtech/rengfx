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

        // cam following the first box
        auto cam1_nt = create_entity("cam1");
        auto cam1 = cam1_nt.add_component(new SceneCamera2D());
        cam1_nt.add_component(new CameraFollow2D(box1, 0.05));
        auto left_half_output_rect = Rectangle(
            0, 0,
            Core.window.screen_width / 2,
            Core.window.screen_height
        );
        add_viewport(cam1, left_half_output_rect);

        // cam following the second box
        auto cam2_nt = create_entity("cam2");
        auto cam2 = cam2_nt.add_component(new SceneCamera2D());
        cam2_nt.add_component(new CameraFollow2D(box2, 0.05));
        auto right_half_output_rect = Rectangle(
            Core.window.screen_width / 2, 0,
            Core.window.screen_width / 2,
            Core.window.screen_height
        );
        add_viewport(cam2, right_half_output_rect);
    }
}
