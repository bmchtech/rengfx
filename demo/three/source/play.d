module play;

import re;
import re.gfx;
import re.gfx.shapes.cube;
import re.gfx.shapes.grid;
import re.ng.camera;
import re.math;
static import raylib;

class PlayScene : Scene3D {
    private PostProcessor glitch_postproc;
    private float[2] aberrationOffset = [0.01, 0];

    override void on_start() {
        clear_color = Colors.LIGHTGRAY;

        // load the effect and add it as a postprocessor
        auto chrm_abr = Effect(Core.content.load_shader(null,
                "chromatic_aberration.frag"), color_alpha_white(0.8));
        glitch_postproc = new PostProcessor(resolution, chrm_abr);
        glitch_postproc.enabled = false;
        postprocessors ~= glitch_postproc;

        cam.entity.position = Vector3(0, 10, 10);
        cam.camera.target = Vector3(0, 0, 0);
        cam.camera.up = Vector3(0, 1, 0);
        cam.camera.fovy = (C_PI_4) * C_RAD2DEG; // 45 deg
        cam.camera.type = CameraType.CAMERA_PERSPECTIVE;

        auto block = create_entity("block", Vector3(0, 0, 0));
        auto cube = block.add_component(new Cube(Vector3(2, 2, 2)));

        camera_nt.add_component(new CameraOrbit(block, 0.5));

        // enable an example shader on cube
        auto cross_stitch = Effect(Core.content.load_shader(null,
                "cross_stitch.frag"), Colors.PURPLE);
        auto mixAmt = 0.05f;
        cross_stitch.set_shader_var("mixAmt", mixAmt);
        cube.effect = cross_stitch;

        auto grid = create_entity("grid");
        grid.add_component(new Grid3D(10, 1));
    }

    override void update() {
        super.update();

        if (Input.is_key_pressed(Keys.KEY_SPACE)) {
            glitch_postproc.enabled = !glitch_postproc.enabled;
        }

        // make our postprocess effect fluctuate
        import std.math : sin;

        aberrationOffset[0] = 0.010 + 0.005 * sin(Time.total_time / 2);
        glitch_postproc.effect.set_shader_var("aberrationOffset", aberrationOffset);
    }

    override void render() {
        super.render();
    }
}
