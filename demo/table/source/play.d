module play;

import re;
import re.gfx;
import re.gfx.shapes.model;
import re.gfx.shapes.grid;
import re.gfx.shapes.cube;
import re.ng.camera;
import re.math;
static import raylib;

/// simple 3d demo scene
class PlayScene : Scene3D {
    private PostProcessor glitch_postproc;
    private float[2] sample_offset = [0.005, 0];

    override void on_start() {
        clear_color = Colors.LIGHTGRAY;

        // load shader effects and add as a postprocessor
        auto ascii_shd = new Effect(Core.content.load_shader(null, "shader/ascii.frag").front, Colors.WHITE);
        ascii_shd.set_shader_var_imm("i_resolution", cast(float[3])[
                resolution.x, resolution.y, 1.0
            ]);
        auto ascii_postproc = new PostProcessor(resolution, ascii_shd);
        postprocessors ~= ascii_postproc;

        auto chrm_abr = new Effect(Core.content.load_shader(null,
                "shader/chromatic_aberration.frag").front, color_alpha_white(0.8));
        chrm_abr.set_shader_var("sample_offset", sample_offset);
        glitch_postproc = new PostProcessor(resolution, chrm_abr);
        postprocessors ~= glitch_postproc;

        // set the camera position
        cam.entity.position = Vector3(10, 10, 10);

        auto fox = create_entity("fox", Vector3(0, 0, 0));
        auto fox_asset = Core.content.load_model("models/fox.obj").front;
        auto fox_model = fox.add_component(new Model3D(fox_asset));
        auto cub = fox.add_component(new Cube(Vector3(1, 1, 1), Colors.GREEN));
        cub.offset = Vector3(0, -4, 0);

        // add a camera to look at the fox
        cam.entity.add_component(new CameraOrbit(fox, 0.2));
        // cam.entity.add_component(new CameraFreeLook(fox));

        // draw a grid at the origin
        auto grid = create_entity("grid");
        grid.add_component(new Grid3D(20, 1));
    }

    override void update() {
        super.update();

        if (Input.is_mouse_pressed(MouseButton.MOUSE_BUTTON_LEFT)) {
            if (Input.is_cursor_locked) {
                Input.unlock_cursor();
            } else {
                Input.lock_cursor();
            }
        }
    }
}
