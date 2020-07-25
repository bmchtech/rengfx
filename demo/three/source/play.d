module play;

import re;
import re.gfx;
import re.gfx.shapes.cube;
import re.gfx.shapes.grid;
import re.math;
static import raylib;

class PlayScene : Scene3D {
    private PostProcessor cool_postproc;

    override void on_start() {
        clear_color = Colors.LIGHTGRAY;

        // load the effect and add it as a postprocessor
        auto chrm_abr = Effect(Core.content.load_shader(null,
                "chromatic_aberration.frag"), color_alpha_white(0.8));
        cool_postproc = new PostProcessor(resolution, chrm_abr);
        cool_postproc.enabled = false;
        postprocessors ~= cool_postproc;

        auto cam = &camera;
        cam.position = Vector3(0, 10, 10);
        camera.target = Vector3(0, 0, 0);
        camera.up = Vector3(0, 1, 0);
        camera.fovy = (C_PI_4) * C_RAD2DEG; // 45 deg
        camera.type = CameraType.CAMERA_PERSPECTIVE;
        raylib.SetCameraMode(camera, raylib.CameraMode.CAMERA_ORBITAL);

        auto block = create_entity("block", Vector3(0, 0, 0));
        auto cube = block.add_component(new Cube(Vector3(2, 2, 2), Colors.PURPLE));

        // enable an example shader on cube
        auto cross_stitch = Core.content.load_shader(null, "cross_stitch.frag");
        auto mix_loc = raylib.GetShaderLocation(cross_stitch, "mixAmt");
        float mix_val = 0.05;
        raylib.SetShaderValue(cross_stitch, mix_loc, &mix_val,
                raylib.ShaderUniformDataType.UNIFORM_FLOAT);
        cube.model.materials[0].shader = cross_stitch;

        auto grid = create_entity("grid");
        grid.add_component(new Grid3D(10, 1));
    }

    override void update() {
        super.update();

        if (Input.is_key_pressed(Keys.KEY_SPACE)) {
            cool_postproc.enabled = !cool_postproc.enabled;
        }
    }
}
