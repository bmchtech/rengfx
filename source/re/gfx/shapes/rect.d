/** color filled rectangle */

module re.gfx.shapes.rect;

import re.ecs;
import re.gfx;
import re.math;
import re.ng.diag;
static import raylib;

/// a color-filled rectangle
class ColorRect : Component, Renderable2D {
    mixin Reflect;
    /// rectangle dimensions
    public Vector2 size;
    /// fill color
    public Color color;

    this(Vector2 size, raylib.Color color, bool fill = true) {
        this.size = size;
        this.color = color;
    }

    @property Rectangle bounds() {
        return Bounds.calculate(entity.transform, size / 2, size.x, size.y);
    }

    void render() {
        raylib.DrawRectanglePro(Rectangle(entity.position2.x,
                entity.position2.y, size.x, size.y), size / 2,
                entity.transform.rotation_z * C_RAD2DEG, color);
    }

    void debug_render() {
        DebugRender.default_debug_render(this);
    }
}
