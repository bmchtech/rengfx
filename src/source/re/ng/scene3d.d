module re.ng.scene3d;

public import re.time;
static import raylib;
import re;
import std.string;
import re.ecs;
import re.math;

abstract class Scene3D : Scene {
    /// the 3d scene camera
    public raylib.Camera3D camera;

    override void begin() {
        super.begin();

        camera = raylib.Camera3D();
    }

    override void render_scene() {
        raylib.BeginMode3D(camera);

        // render 3d components
        foreach (component; ecs.storage.renderable_components) {
            auto renderable = cast(Renderable3D) component;
            assert(renderable !is null, "renderable was not 3d");
            renderable.render();
            if (Core.debug_render) {
                renderable.debug_render();
            }
        }

        raylib.EndMode3D();
    }
}