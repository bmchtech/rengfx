module re.gfx.shapes.cube;

import re.ecs;
import re.gfx;
import re.math;
static import raylib;

/// represents a 3d rectangular prism (we abbreviate as cube)
class Cube : Component, Renderable3D {
    /// rectangular prism dimensions
    public Vector3 size;
    /// color
    public Color color;

    this(Vector3 size, Color color) {
        this.size = size;
        this.color = color;
    }

    public void render() {
        raylib.DrawCubeV(entity.position, size, color);
    }

    public void debug_render() {
        raylib.DrawCubeWiresV(entity.position, size, Colors.RED);
    }
}
