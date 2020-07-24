module re.ng.scene2d;

public import re.time;
static import raylib;
import re;
import std.string;
import re.ecs;
import re.math;

abstract class Scene2D : Scene {
    override void render_scene() {
        // render components
        foreach (component; ecs.storage.renderable_components) {
            auto renderable = cast(Renderable) component;
            renderable.render();
            if (Core.debug_render) {
                renderable.debug_render();
            }
        }
    }
}
