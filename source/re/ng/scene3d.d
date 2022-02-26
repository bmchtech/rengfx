/** scene with 3d rendering */

module re.ng.scene3d;

static import raylib;
public import raylib : Camera3D;
import re.ng.camera;
import re;
import std.string;
import re.ecs;
import re.math;

/// represents a scene rendered in 3d
abstract class Scene3D : Scene {
    /// the 3d scene camera
    public SceneCamera3D cam;

    override void setup() {
        super.setup();

        // create a camera entity
        auto camera_nt = create_entity("camera");
        cam = camera_nt.add_component(new SceneCamera3D());
    }

    void render_renderable(Component component) {
        auto renderable = cast(Renderable3D) component;
        assert(renderable !is null, "renderable was not 3d");
        renderable.render();
        if (Core.debug_render) {
            renderable.debug_render();
        }
    }

    override void render_scene() {
        raylib.BeginMode3D(cam.camera);

        // render 3d components
        foreach (component; ecs.storage.renderable_components) {
            render_renderable(component);
        }
        foreach (component; ecs.storage.updatable_renderable_components) {
            render_renderable(component);
        }

        render_hook();

        raylib.EndMode3D();
    }

    override void update() {
        super.update();

        cam.update();
    }
}
