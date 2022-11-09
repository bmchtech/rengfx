module play;

import std.stdio;
import optional;

import re;
import re.gfx;
import re.gfx.shapes.model;
import re.gfx.shapes.grid;
import re.gfx.shapes.cube;
import re.gfx.shapes.sphere;
import re.gfx.lighting.basic;
import re.gfx.effects.frag;
import re.ng.camera;
import re.math;
import re.util.orbit;
static import raylib;

import app;

/// simple 3d demo scene
class PlayScene : Scene3D {

    PostProcessor cel2_postproc;
    PostProcessor bokeh_postproc;
    Entity mdl1;

    override void on_start() {
        clear_color = Colors.LIGHTGRAY;

        // set the camera position
        cam.entity.position = Vector3(6, 6, 6);

        // enable scene lighting
        auto lights = add_manager(new BasicSceneLightManager());
        lights.ambient = 0.4;
        lights.light_clamp = 0.2;
        lights.shine_amount = 16;
        lights.light_quantize = true;

        // create a point light
        auto light1 = create_entity("light1");
        auto light1_essence = light1.add_component(new Light3D(color_rgb(255, 255, 255)));
        light1.add_component(new Sphere(0.2, 16, 16, light1_essence.color));
        light1.add_component(new Orbit(Vector3(2, 8, 0), 10, C_PI / 8));

        auto mdl_asset_path = "models/nieradam.glb";
        if (Game.custom_mdl1_path) {
            mdl_asset_path = Game.custom_mdl1_path;
        }
        mdl1 = create_entity("mdl1", Vector3(0, 0, 0));
        auto mdl1_asset = Core.content.load_model(mdl_asset_path);
        auto mdl1_model = mdl1.add_component(new Model3D(mdl1_asset.front));
        // mdl1.transform.scale = Vector3(0.4, 0.4, 0.4);
        // mdl1.transform.orientation = Vector3(C_PI / 2, 0, 0);
        mdl1_model.effect = new Effect(lights.shader, Colors.WHITE);
        // auto cub = mdl1.add_component(new Cube(Vector3(1, 1, 1), Colors.GREEN));
        // cub.offset = Vector3(0, -4, 0);

        auto blk1 = create_entity("blk1", Vector3(2, 0.5, 0.5));
        auto blk1_asset = Core.content.load_model("models/rcube.glb");
        auto blk1_model = blk1.add_component(new Model3D(blk1_asset.front));
        blk1.transform.scale = Vector3(0.5, 0.5, 0.5);
        blk1_model.effect = new Effect(lights.shader, Colors.WHITE);

        auto qsphr1 = create_entity("qsphr1", Vector3(-1, 0, -1));
        auto qsphr1_asset = Core.content.load_model("models/qsphr.glb");
        auto qsphr1_model = qsphr1.add_component(new Model3D(qsphr1_asset.front));
        qsphr1.transform.scale = Vector3(0.5, 0.5, 0.5);
        qsphr1_model.effect = new Effect(lights.shader, Colors.WHITE);

        auto sphr1 = create_entity("sphr1", Vector3(-1, 0.5, 1.5));
        auto sphr1_asset = Core.content.load_model("models/sphr.glb");
        auto sphr1_model = sphr1.add_component(new Model3D(sphr1_asset.front));
        sphr1.transform.scale = Vector3(0.5, 0.5, 0.5);
        sphr1_model.effect = new Effect(lights.shader, Colors.WHITE);

        // add a camera to look at the mdl1
        if (Game.free_look) {
            set_free_cam();
        } else {
            set_orbit_cam();
        }

        // // draw a grid at the origin
        // auto grid = create_entity("grid");
        // grid.add_component(new Grid3D(20, 1));
        auto floor = create_entity("floor", Vector3(0, -5, 0));
        auto floor_col = color_rgb(168, 156, 146);
        auto floor_box = floor.add_component(new Cube(Vector3(40, 10, 40), floor_col));
        // floor_box.effect = new Effect(lights.shader, floor_col);

        auto cel2 = new FragEffect(this, Core.content.load_shader(null, "shader/cel_light.frag").front);
        cel2.set_shader_var_imm("outline_diag", cast(float) 8);
        cel2.set_shader_var_imm("outline_div", cast(float) 8);
        cel2.set_shader_var_imm("outline_lighten", cast(float) 0.1);
        cel2_postproc = new PostProcessor(resolution, cel2);
        postprocessors ~= cel2_postproc;

        auto bokeh = new FragEffect(this, Core.content.load_shader(null, "shader/bokeh.frag").front);
        bokeh.set_shader_var_imm("bokeh_base", cast(float) 0.005);
        bokeh.set_shader_var_imm("bokeh_maxv", cast(float) 1000);
        bokeh.set_shader_var_imm("bokeh_focus_dist", cast(float) 5);
        bokeh_postproc = new PostProcessor(resolution, bokeh);
        // postprocessors ~= bokeh_postproc;
    }

    void set_free_cam() {
        auto cam_control = new CameraFreeLook(mdl1);
        cam_control.target_offset = Vector3(0, 1, 0);
        cam.entity.add_component(cam_control);
    }

    void set_orbit_cam() {
        cam.entity.position = Vector3(6, 6, 6);
        cam.entity.add_component(new CameraOrbit(mdl1, 0.2));
        // cam.entity.position = Vector3(3, 3, 3);
        // auto cam_control = new CameraThirdPerson(mdl1);
        // cam_control.target_offset = Vector3(0, 1, 0);
        // cam.entity.add_component(cam_control);
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

        // if SPACE is pressed, toggle camera orbit vs free look
        if (Input.is_key_pressed(Keys.KEY_F)) {
            if (cam.entity.has_component!CameraOrbit) {
                cam.entity.remove_component!CameraOrbit;
                set_free_cam();
            } else if (cam.entity.has_component!CameraFreeLook) {
                cam.entity.remove_component!CameraFreeLook;
                set_orbit_cam();
            }
        }
    }
}
