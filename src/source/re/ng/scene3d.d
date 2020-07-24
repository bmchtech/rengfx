module re.ng.scene3d;

static import raylib;
public import raylib : Camera3D, CameraMode, CameraType;
import re;
import std.string;
import re.ecs;
import re.math;

/// represents a scene rendered in 3d
abstract class Scene3D : Scene {
    /// the 3d scene camera
    public Camera3D camera;

    override void begin() {
        super.begin();

        camera = Camera3D();
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
