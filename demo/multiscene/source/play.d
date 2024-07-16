module play;

static import raylib;

import re;
import re.gfx;
import re.gfx.shapes.rect;
import re.ng.camera;
import re.math;
import re.phys.kin2d;

import std.stdio;

class PlayScene : Scene2D {
    override void setup() {
        use_default_viewport = false;
        super.setup();
    }

    override void on_start() {
        auto bg_tween = Tweener.tween(clear_color, Colors.DARKGRAY,
            Colors.LIGHTGRAY, 2, &Ease.QuadIn);
        bg_tween.start();

        auto box1 = create_entity("box1", Vector2(20, 20));
        box1.add_component(new ColorRect(Vector2(8, 8), Colors.BLUE));
        auto box1_body = box1.add_component!KinBody2D();
        box1_body.angular_accel = 0.1;

        auto box2 = create_entity("box2", Vector2(60, 40));
        box2.add_component(new ColorRect(Vector2(8, 8), Colors.RED));
        auto box2_body = box2.add_component!KinBody2D();
        box2_body.angular_accel = -0.07;

        // custom viewports with custom cameras
        auto half_vp_resolution = Vector2(100, 100);

        // cam following the first box
        auto cam1_nt = create_entity("cam1");
        auto cam1 = cam1_nt.add_component(new SceneCamera2D());
        auto left_half_output_bounds = Rectangle(
            0, 0,
            Core.window.screen_width / 2,
            Core.window.screen_height
        );
        auto vp1 = add_viewport(cam1, left_half_output_bounds, half_vp_resolution);
        auto follow1 = cam1_nt.add_component(new CameraFollow2D(vp1, box1, 0.05));

        // cam following the second box
        auto cam2_nt = create_entity("cam2");
        auto cam2 = cam2_nt.add_component(new SceneCamera2D());
        auto right_half_output_bounds = Rectangle(
            Core.window.screen_width / 2, 0,
            Core.window.screen_width / 2,
            Core.window.screen_height
        );
        auto vp2 = add_viewport(cam2, right_half_output_bounds, half_vp_resolution);
        auto follow2 = cam2_nt.add_component(new CameraFollow2D(vp2, box2, 0.05));
        follow2.follow_rotation = true;
    }
}
