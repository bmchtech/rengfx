/** base interface for renderable components */

module re.ecs.renderable;

import re.math;

/// a component that can be rendered (drawn)
interface Renderable {
    void render();
    void debug_render();
}

interface Renderable2D : Renderable {
    @property Rectangle bounds();
}

interface Renderable3D : Renderable {
    @property BoundingBox bounds();
}
