module play;

import re;
import re.gfx;
import re.gfx.shapes.cube;
import re.gfx.shapes.grid;
import re.math;
static import raylib;

class PlayScene : Scene3D {
    private PostProcessor grayscale_postproc;

    override void on_start() {
        clear_color = Colors.LIGHTGRAY;

        // load the grayscale effect and add it as a postprocessor
        auto grayscale_effect = Effect(Core.content.load_shader(null,
                "grayscale.frag"), color_alpha_white(0.8));
        grayscale_postproc = new PostProcessor(resolution, grayscale_effect);
        grayscale_postproc.enabled = false;
        postprocessors ~= grayscale_postproc;

        auto cam = &camera;
        cam.position = Vector3(0, 10, 10);
        camera.target = Vector3(0, 0, 0);
        camera.up = Vector3(0, 1, 0);
        camera.fovy = (C_PI_4) * C_RAD2DEG; // 45 deg
        camera.type = CameraType.CAMERA_PERSPECTIVE;
        raylib.SetCameraMode(camera, raylib.CameraMode.CAMERA_ORBITAL);

        auto block = create_entity("block", Vector3(0, 0, 0));
        auto cube = block.add_component(new Cube(Vector3(2, 2, 2), Colors.PURPLE));

        // enable grayscale shader on cube
        // cube.model.materials[0].shader = grayscale_effect.shader;

        auto grid = create_entity("grid");
        grid.add_component(new Grid3D(10, 1));
    }

    override void update() {
        super.update();

        if (Input.is_key_pressed(Keys.KEY_SPACE)) {
            grayscale_postproc.enabled = !grayscale_postproc.enabled;
        }
    }
}
