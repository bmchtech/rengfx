module things;

import re.ecs;
import re.gfx;
import re.math;
static import raylib;

class Cube : Component, Renderable3D {
    public void render() {
        raylib.DrawCube(entity.position, 2, 2, 2, Colors.RED);
    }

    public void debug_render() {
    }
}

class Grid : Component, Renderable3D {
    public void render() {
        raylib.DrawGrid(10, 1);
    }

    public void debug_render() {
    }
}
