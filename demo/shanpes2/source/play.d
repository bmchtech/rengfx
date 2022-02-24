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

    override void on_start() {
        clear_color = Colors.LIGHTGRAY;

        // set the camera position
        cam.entity.position = Vector3(6, 6, 6);

        auto fox = create_entity("fox", Vector3(0, -0.07, 0));
        auto fox_asset = Core.content.load_model("models/fox.obj");
        auto fox_model = fox.add_component(new Model3D(fox_asset));
        fox.transform.scale = Vector3(0.4, 0.4, 0.4);
        // auto cub = fox.add_component(new Cube(Vector3(1, 1, 1), Colors.GREEN));
        // cub.offset = Vector3(0, -4, 0);

        auto blk1 = create_entity("blk1", Vector3(2, 0.5, 0.5));
        auto blk1_asset = Core.content.load_model("models/rcube.glb");
        auto blk1_model = blk1.add_component(new Model3D(blk1_asset));
        blk1.transform.scale = Vector3(0.5, 0.5, 0.5);

        auto qsphr1 = create_entity("qsphr1", Vector3(-1, 0, -1));
        auto qsphr1_asset = Core.content.load_model("models/qsphr.glb");
        auto qsphr1_model = qsphr1.add_component(new Model3D(qsphr1_asset));
        qsphr1.transform.scale = Vector3(0.5, 0.5, 0.5);

        auto sphr1 = create_entity("sphr1", Vector3(-1, 0.5, 1.5));
        auto sphr1_asset = Core.content.load_model("models/sphr.glb");
        auto sphr1_model = sphr1.add_component(new Model3D(sphr1_asset));
        sphr1.transform.scale = Vector3(0.5, 0.5, 0.5);

        // add a camera to look at the fox
        cam.entity.add_component(new CameraOrbit(fox, 0.2));
        // cam.entity.add_component(new CameraFreeLook(fox));

        // // draw a grid at the origin
        // auto grid = create_entity("grid");
        // grid.add_component(new Grid3D(20, 1));
        auto floor = create_entity("floor", Vector3(0, -5, 0));
        auto floor_box = floor.add_component(new Cube(Vector3(40, 10, 40), color_rgb(168, 156, 146)));

        auto cel2 = Effect(Core.content.load_shader(null,
                "shader/cel_light.frag"), Colors.WHITE);
        cel2.set_shader_var_imm("c_resolution", cast(float[2])[
                resolution.x, resolution.y
            ]);
        auto cel2_postproc = new PostProcessor(resolution, cel2);
        postprocessors ~= cel2_postproc;
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
