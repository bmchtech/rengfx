module play;

import re;
import re.gfx;
import re.gfx.shapes.cube;
import re.gfx.shapes.grid;
import re.ng.camera;
import re.phys.collider;
import re.phys.nudge;
import re.math;
static import raylib;

/// simple 3d demo scene
class PlayScene : Scene3D {
    override void on_start() {
        clear_color = Colors.LIGHTGRAY;

        // set the camera position
        cam.entity.position = Vector3(0, 30, 20);

        // draw a grid at the origin
        auto grid = create_entity("grid");
        grid.add_component(new Grid3D(20, 1));

        auto floor = create_entity("floor", Vector3(0, -10, 0));
        floor.add_component(new Cube(Vector3(40, 4, 40), Colors.GRAY));
        floor.add_component(new BoxCollider(Vector3(400, 10, 400), Vector3(0, -10, 0)));
        auto floor_body = floor.add_component(new NudgeBody());
        floor_body.is_static = true;

        // create a block, and assign it a physics object
        auto block = create_entity("block", Vector3(0, 20, 0));
        block.add_component(new Cube(Vector3(2, 2, 2), Colors.BLUE));
        block.add_component(new BoxCollider(Vector3(2, 2, 2), Vector3Zero));
        auto block_body = block.add_component(new NudgeBody());
        block_body.is_static = true;

        // make small blocks
        for (int i = 0; i < 20; i++) {
            auto x_off = Rng.next_float() * 6;
            auto z_off = Rng.next_float() * 6;

            auto nt = create_entity("thing", Vector3(x_off, 40, z_off));
            nt.add_component(new Cube(Vector3(0.5, 0.5, 0.5), Colors.GREEN));
            nt.add_component(new BoxCollider(Vector3(0.5, 0.5, 0.5), Vector3Zero));
            auto thing_body = nt.add_component(new NudgeBody());
        }

        // point the camera at the block, then orbit it
        cam.look_at(block);
        // cam.entity.add_component(new CameraOrbit(block, 0.15));
        cam.entity.add_component(new CameraFreeLook(block));
    }
}
