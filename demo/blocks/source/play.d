module play;

import re;
import re.gfx;
import re.gfx.shapes.cube;
import re.gfx.shapes.grid;
import re.ng.camera;
import re.phys.collider;
import re.phys.rigid3d;
import re.math;
static import raylib;

/// simple 3d demo scene
class PlayScene : Scene3D {
    override void on_start() {
        clear_color = Colors.LIGHTGRAY;

        // set the camera position
        cam.entity.position = Vector3(0, 10, 20);

        // draw a grid at the origin
        // auto grid = create_entity("grid");
        // grid.add_component(new Grid3D(20, 1));

        auto floor = create_entity("floor", Vector3(0, -5, 0));
        floor.add_component(new Cube(Vector3(40, 10, 40), Colors.GRAY));
        floor.add_component(new BoxCollider(Vector3(20, 5, 20), Vector3Zero));
        floor.add_component(new StaticBody());

        // create a block, and assign it a physics object
        auto block = create_entity("block", Vector3(0, 5, 0));
        block.transform.orientation = raymath.QuaternionFromEuler(0, C_PI_4, C_PI_4);
        block.add_component(new Cube(Vector3(4, 4, 4), Colors.BLUE));
        block.add_component(new BoxCollider(Vector3(2, 2, 2), Vector3Zero));
        auto block_body = block.add_component(new DynamicBody());
        block_body.mass = 64;

        // make small blocks
        // enum small_block_count = 256;
        enum small_block_count = 10;
        enum small_block_spread = 10;
        for (int i = 0; i < small_block_count; i++) {
            auto x_off = Rng.next_float() * small_block_spread * 2 - small_block_spread;
            auto y_off = Rng.next_float() * small_block_spread * 4;
            auto z_off = Rng.next_float() * small_block_spread * 2 - small_block_spread;

            auto x_ang = Rng.next_float() * C_2_PI;
            auto y_ang = Rng.next_float() * C_2_PI;
            auto z_ang = Rng.next_float() * C_2_PI;

            static import raymath;

            auto nt = create_entity("thing", Vector3(x_off, y_off, z_off));
            nt.transform.orientation = raymath.QuaternionFromEuler(x_ang, y_ang, z_ang);
            nt.add_component(new Cube(Vector3(1, 1, 1), Colors.ORANGE));
            nt.add_component(new BoxCollider(Vector3(0.5, 0.5, 0.5), Vector3Zero));
            auto thing_body = nt.add_component(new DynamicBody());
            thing_body.mass = 2;
        }

        // point the camera at the block, then orbit it
        cam.look_at(block);
        // cam.entity.add_component(new CameraOrbit(block, 0.15));
        cam.entity.add_component(new CameraFreeLook(block));
    }
}
