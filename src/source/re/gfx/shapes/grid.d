module re.gfx.shapes.grid;

import re.ecs;
import re.gfx;
import re.math;
static import raylib;

/// represents a 3d grid at the origin
class Grid3D : Component, Renderable3D {
    public int slices;
    public float spacing;

    this(int slices, float spacing) {
        this.slices = slices;
        this.spacing = spacing;
    }

    public void render() {
        raylib.DrawGrid(slices, spacing);
    }

    public void debug_render() {
    }
}
