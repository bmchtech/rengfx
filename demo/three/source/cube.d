module cube;

import re.ecs;
import re.gfx;
import re.math;
static import raylib;


class Cube : Component, Renderable3D {
    override void setup() {

    }

    public void render() {
        raylib.DrawCube(entity.position, 2, 2, 2, Colors.RED);
    }

    public void debug_render() {
    }
}
