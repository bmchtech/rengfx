module play;

import re;
import re.gfx;
import re.gfx.shapes.cube;
import re.gfx.shapes.grid;
import re.ng.camera;
import re.phys.nudge;
import re.math;
static import raylib;

/// simple 3d demo scene
class PlayScene : Scene3D {
    override void on_start() {
        clear_color = Colors.LIGHTGRAY;

        // set the camera position
        cam.entity.position = Vector3(0, 10, 10);

        // create a block, and assign it a physics object
        auto block = create_entity("block", Vector3(0, 0, 0));
        block.add_component(new Cube(Vector3(2, 2, 2), Colors.BLUE));
        block.add_component(new NudgeBody());

        // point the camera at the block, then orbit it
        cam.look_at(block);
        cam.entity.add_component(new CameraOrbit(block, 0.15));

        // draw a grid at the origin
        auto grid = create_entity("grid");
        grid.add_component(new Grid3D(20, 1));
    }
}
