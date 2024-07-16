/** scene with 3d rendering */

module re.ng.scene3d;

static import raylib;
import re.ng.camera;
import re;
import re.gfx;
import re.ecs;
import re.math;

import std.string;

/// represents a scene rendered in 3d
abstract class Scene3D : Scene {
    override void setup() {
        super.setup();
    }

    override void create_default_viewport() {
        // create a camera entity
        auto camera_nt = create_entity("camera");
        auto cam = camera_nt.add_component(new SceneCamera3D());

        add_viewport(cam, Core.window.screen_bounds, resolution);
    }

    Viewport3D add_viewport(SceneCamera3D cam, Rectangle output_rect, Vector2 resolution) {
        auto vp = new Viewport3D();
        vp.cam = cam;
        vp.output_rect = output_rect;
        vp.render_target = RenderExt.create_render_target(
            cast(int) resolution.x, cast(int) resolution.y
        );
        viewports ~= vp;
        return vp;
    }

    void render_renderable(Component component) {
        auto renderable = cast(Renderable3D) component;
        assert(renderable !is null, "renderable was not 3d");
        renderable.render();
        if (Core.debug_render) {
            renderable.debug_render();
        }
    }

    override void render_scene(Viewport viewport) {
        version (vr) {
            if (Core.vr.enabled)
                raylib.BeginVrStereoMode(Core.vr.config);
        }

        Viewport3D vp = cast(Viewport3D) viewport;
        raylib.BeginMode3D(vp.cam.camera);

        // render 3d components
        foreach (component; ecs.storage.renderable_components) {
            render_renderable(component);
        }
        foreach (component; ecs.storage.updatable_renderable_components) {
            render_renderable(component);
        }

        render_hook();

        raylib.EndMode3D();

        version (vr) {
            if (Core.vr.enabled)
                raylib.EndVrStereoMode();
        }
    }

    override void update() {
        super.update();
    }

    override void unload() {
        super.unload();
    }
}
