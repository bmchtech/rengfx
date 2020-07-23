module comp.square;

import re.ecs;
import re.math;
static import raylib;

class Square : Component, Renderable {
    public Vector2 size;
    public raylib.Color color;

    this(Vector2 size, raylib.Color color) {
        this.size = size;
        this.color = color;
    }

    @property Rectangle bounds() {
        return Rectangle(entity.position2.x, entity.position2.y, size.x, size.y);
    }

    void render() {
        raylib.DrawRectanglePro(Rectangle(entity.position2.x,
                entity.position2.y, size.x, size.y), size / 2, entity.transform.rotation * RAD2DEG, color);
    }

    void debug_render() {
    }
}
