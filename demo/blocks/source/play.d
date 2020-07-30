module play;

import re;
import re.gfx;
import re.gfx.shapes.cube;
import re.gfx.shapes.grid;
import re.ng.camera;
import re.phys.collider;
import re.phys.rigid3d;
import re.math;
import comp.input;
import comp.body;
static import raylib;

/// simple 3d demo scene
class PlayScene : Scene3D {
    override void on_start() {
        clear_color = Colors.LIGHTGRAY;

        // load a shader effect and add it as a postprocessor
        auto cel_ish = Effect(Core.content.load_shader(null, "shader/cel_ish.frag"));
        cel_ish.set_shader_var_imm("c_threshold", 0.2f);
        cel_ish.set_shader_var_imm("c_resolution", cast(float[2]) [resolution.x, resolution.y]);
        auto postproc = new PostProcessor(resolution, cel_ish);
        postprocessors ~= postproc;

        // set the camera position
        cam.entity.position = Vector3(0, 10, 20);

        PhysicsManager.max_collisions = 4096;

        auto floor = create_entity("floor", Vector3(0, -5, 0));
        floor.add_component(new Cube(Vector3(40, 10, 40), color_rgb(82, 80, 68)));
        floor.add_component(new BoxCollider(Vector3(20, 5, 20), Vector3Zero));
        floor.add_component(new StaticBody());

        // create a block, and assign it a physics object
        auto block = create_entity("block", Vector3(0, 5, 0));
        block.transform.orientation = Vector3(0, C_PI_4, C_PI_4); // euler angles
        block.add_component(new Cube(Vector3(4, 4, 4), color_rgb(141, 113, 176)));
        block.add_component(new BoxCollider(Vector3(2, 2, 2), Vector3Zero));
        block.add_component(new DynamicBody(64));
        block.add_component!PlayerController();
        block.add_component!Character();

        // make small blocks
        // enum small_block_count = 128;
        // enum small_block_spread = 10;
        // for (int i = 0; i < small_block_count; i++) {
        //     import re.math.funcs;

        //     auto x_off = Distribution.normalRand(0, small_block_spread / 4);
        //     auto y_off = Rng.next_float() * small_block_spread * 4;
        //     auto z_off = Distribution.normalRand(0, small_block_spread / 4);

        //     auto x_ang = Rng.next_float() * C_2_PI;
        //     auto y_ang = Rng.next_float() * C_2_PI;
        //     auto z_ang = Rng.next_float() * C_2_PI;

        //     static import raymath;

        //     auto nt = create_entity("thing", Vector3(x_off, y_off, z_off));
        //     nt.transform.orientation = Vector3(x_ang, y_ang, z_ang); // euler angles
        //     nt.add_component(new Cube(Vector3(1, 1, 1), color_rgb(209, 153, 56)));
        //     nt.add_component(new BoxCollider(Vector3(0.5, 0.5, 0.5), Vector3Zero));
        //     auto thing_body = nt.add_component(new DynamicBody(2));
        // }

        // point the camera at the block, then orbit it
        cam.look_at(block);
        cam.entity.add_component(new CameraFreeLook(block));
    }
}
