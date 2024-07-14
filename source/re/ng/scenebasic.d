/** scene with manual rendering */

module re.ng.scenebasic;

static import raylib;
public import raylib : Camera2D;
import re.ng.camera;
import re;
import std.string;
import re.ecs;
import re.math;

/// represents a scene with manual rendering without a 2d/3d camera
abstract class SceneBasic : Scene {
    override void setup() {
        super.setup();
    }

    void render_renderable(Component component) {
        auto renderable = cast(Renderable) component;
        renderable.render();
        if (Core.debug_render) {
            renderable.debug_render();
        }
    }

    override void render_scene() {
        // render 2d components
        foreach (component; ecs.storage.renderable_components) {
            render_renderable(component);
        }
        foreach (component; ecs.storage.updatable_renderable_components) {
            render_renderable(component);
        }

        render_hook();
    }
}
