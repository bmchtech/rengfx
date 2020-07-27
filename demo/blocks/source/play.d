module play;

import re;
import re.gfx;
import re.gfx.shapes.model;
import re.gfx.shapes.grid;
import re.ng.camera;
import re.math;
static import raylib;

/// simple 3d demo scene
class PlayScene : Scene3D {
    override void on_start() {
        clear_color = Colors.LIGHTGRAY;

// create a block, and assign it a physics object

        // draw a grid at the origin
        auto grid = create_entity("grid");
        grid.add_component(new Grid3D(20, 1));
    }
}
