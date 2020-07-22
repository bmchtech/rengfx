module re.ecs.renderable;

import re.math;

interface Renderable {
    @property Rectangle bounds();
    void render();
    void debug_render();
}