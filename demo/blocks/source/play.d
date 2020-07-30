module play;

import re;
import re.math;
import re.gfx;
import re.ng.camera;
import re.phys.collider;
import re.phys.rigid3d;
import re.gfx.shapes.cube;
import re.gfx.shapes.grid;
import re.gfx.lighting;
import comp.input;
import comp.body;
import comp.orbit;

/// simple 3d demo scene
class PlayScene : Scene3D {
    private Entity light3;

    override void on_start() {
        clear_color = color_rgb(224, 176, 153);

        // load a shader effect and add it as a postprocessor
        auto cel_ish = Effect(Core.content.load_shader(null, "shader/cel_ish.frag"));
        cel_ish.set_shader_var_imm("c_threshold", 0.5f);
        cel_ish.set_shader_var_imm("c_resolution", cast(float[2])[
                resolution.x, resolution.y
                ]);
        auto postproc = new PostProcessor(resolution, cel_ish);
        postprocessors ~= postproc;

        // enable scene lighting
        auto lights = add_manager(new SceneLightManager());

        // enable scene physics
        auto physics = new PhysicsManager();
        physics.max_collisions = 1024;
        physics.gravity = Vector3(0, -16, 0);
        add_manager(physics);

        // set the camera position
        cam.entity.position = Vector3(0, 10, 20);

        // create the static floor
        auto floor = create_entity("floor", Vector3(0, -5, 0));
        floor.add_component(new Cube(Vector3(40, 10, 40), color_rgb(91, 64, 54)));
        floor.add_component(new BoxCollider(Vector3(20, 5, 20), Vector3Zero));
        floor.add_component(new StaticBody());

        // create a block, and assign it a physics object
        auto block = create_entity("block", Vector3(0, 5, 0));
        block.transform.orientation = Vector3(0, C_PI_4, C_PI_4); // euler angles
        auto block_cube = block.add_component(new Cube(Vector3(4, 4, 4)));
        block_cube.effect = Effect(lights.shader, color_rgb(141, 113, 176));
        block.add_component(new BoxCollider(Vector3(2, 2, 2), Vector3Zero));
        block.add_component(new DynamicBody(64));
        block.add_component!PlayerController();
        block.add_component!Character();

        // create a point light
        auto light1 = create_entity("light1");
        light1.add_component(new Light3D(color_rgb(150, 150, 150)));
        light1.add_component(new Orbit(Vector3(0, 8, 0), 10, C_PI / 8));

        auto light2 = create_entity("light2");
        light2.add_component(new Light3D(color_rgb(100, 0, 0, 100)));
        light2.add_component(new Orbit(Vector3(0, 4, 0), 16, C_PI / 8, C_PI));

        light3 = create_entity("light3");
        light3.add_component(new Light3D(color_rgb(0, 0, 100, 100)));
        light3.add_component(new Orbit(Vector3(0, 6, 0), 6, C_PI / 8, C_PI / 4));

        // make small blocks
        enum small_block_count = 160;
        enum small_block_spread = 10;
        for (int i = 0; i < small_block_count; i++) {
            import re.math.funcs : Distribution;

            auto x_off = Distribution.normalRand(0, small_block_spread / 4);
            auto y_off = Rng.next_float() * small_block_spread * 4;
            auto z_off = Distribution.normalRand(0, small_block_spread / 4);

            auto x_ang = Rng.next_float() * C_2_PI;
            auto y_ang = Rng.next_float() * C_2_PI;
            auto z_ang = Rng.next_float() * C_2_PI;

            auto nt = create_entity("thing", Vector3(x_off, y_off, z_off));
            nt.transform.orientation = Vector3(x_ang, y_ang, z_ang); // euler angles
            auto lil_cube = nt.add_component(new Cube(Vector3(1, 1, 1)));
            lil_cube.effect = Effect(lights.shader, color_rgb(209, 107, 56));
            nt.add_component(new BoxCollider(Vector3(0.5, 0.5, 0.5), Vector3Zero));
            auto bod = nt.add_component(new DynamicBody(2));
            bod.bounce = 1.1;
            bod.friction = 0.7;
            bod.sync_properties();
        }

        // point the camera at the center block
        cam.look_at(block);
        cam.entity.add_component(new CameraFreeLook(block));
    }

    override void update() {
        super.update();

        // if Q pressed, remove the third light
        if (Input.is_key_pressed(Keys.KEY_Q)) {
            light3.destroy();
        }
    }
}
