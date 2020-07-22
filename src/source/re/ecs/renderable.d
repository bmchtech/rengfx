module re.ecs.renderable;

import re.math;

/// a component that can be rendered (drawn)
interface Renderable {
    @property Rectangle bounds();
    void render();
    void debug_render();
}