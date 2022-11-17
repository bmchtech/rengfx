module play;

import re;
import re.gfx;
import re.gfx.shapes.anim_model;
import re.gfx.shapes.model;
import re.gfx.shapes.grid;
import re.gfx.shapes.cube;
import re.ng.camera;
import re.math;
static import raylib;

/// simple 3d demo scene
class PlayScene : Scene3D {
    private PostProcessor glitch_postproc;
    private float[2] sample_offset = [0.002, 0];

    override void on_start() {
        clear_color = Colors.LIGHTGRAY;

        // load shader effects and add as a postprocessor
        // auto ascii_shd = new Effect(Core.content.load_shader(null, "shader/ascii.frag").front, Colors.WHITE);
        // ascii_shd.set_shader_var_imm("c_resolution", cast(float[2])[
        //         resolution.x, resolution.y
        //         ]);
        // auto ascii_postproc = new PostProcessor(resolution, ascii_shd);
        // postprocessors ~= ascii_postproc;

        auto chrm_abr = new Effect(Core.content.load_shader(null,
                "shader/chromatic_aberration.frag").front, color_alpha_white(0.8));
        chrm_abr.set_shader_var("sample_offset", sample_offset);
        glitch_postproc = new PostProcessor(resolution, chrm_abr);
        postprocessors ~= glitch_postproc;

        // set the camera position
        cam.entity.position = Vector3(0, 3, 6);

        auto item1 = create_entity("item1", Vector3(0, 0, 0));
        auto item1_asset_path = "models/lg/test1.glb";
        auto item1_asset = Core.content.load_model(item1_asset_path).front;
        auto item1_asset_anims = Core.content.load_model_animations(item1_asset_path).front;
        auto item1_model = item1.add_component(new AnimModel3D(item1_asset, item1_asset_anims));
        // auto item1_model = item1.add_component(new Model3D(item1_asset));
        item1.transform.scale = Vector3(2, 2, 2);

        cam.look_at(item1.transform.position + Vector3(0, 2, 0));

        // add a camera to look at the item1
        cam.entity.add_component(new CameraFreeLook(item1));

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
