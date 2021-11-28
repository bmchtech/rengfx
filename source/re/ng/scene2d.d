module re.ng.scene2d;

static import raylib;
public import raylib : Camera2D;
import re.ng.camera;
import re;
import std.string;
import re.ecs;
import re.math;

/// represents a scene rendered in 2d
abstract class Scene2D : Scene {
    /// the 2d scene camera
    public SceneCamera2D cam;

    override void setup() {
        super.setup();

        // create a camera entity
        auto camera_nt = create_entity("camera");
        cam = camera_nt.add_component(new SceneCamera2D());
    }

    void render_renderable(Component component) {
        auto renderable = cast(Renderable2D) component;
        assert(renderable !is null, "renderable was not 2d");
        renderable.render();
        if (Core.debug_render) {
            renderable.debug_render();
        }
    }

    override void render_scene() {
        raylib.BeginMode2D(cam.camera);

        // render 2d components
        foreach (component; ecs.storage.renderable_components) {
            render_renderable(component);
        }
        foreach (component; ecs.storage.updatable_renderable_components) {
            render_renderable(component);
        }

        render_hook();

        raylib.EndMode2D();
    }

    override void update() {
        super.update();

        cam.update();
    }
}
