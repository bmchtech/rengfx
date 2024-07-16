/** scene with 2d rendering */

module re.ng.scene2d;

static import raylib;
import re.ng.camera;
import re;
import re.gfx;
import re.ecs;
import re.math;

import std.string;

/// represents a scene rendered in 2d
abstract class Scene2D : Scene {
    override void setup() {
        super.setup();
    }

    override void create_default_viewport() {
        // create a camera entity
        auto camera_nt = create_entity("camera");
        auto cam = camera_nt.add_component(new SceneCamera2D());

        add_viewport(cam, Core.window.screen_bounds, resolution);
    }

    Viewport2D add_viewport(SceneCamera2D cam, Rectangle output_rect, Vector2 resolution) {
        auto vp = new Viewport2D();
        vp.cam = cam;
        vp.output_rect = output_rect;
        vp.render_target = RenderExt.create_render_target(
            cast(int) resolution.x, cast(int) resolution.y
        );
        viewports ~= vp;
        return vp;
    }

    void render_renderable(Component component) {
        auto renderable = cast(Renderable2D) component;
        assert(renderable !is null, "renderable was not 2d");
        renderable.render();
        if (Core.debug_render) {
            renderable.debug_render();
        }
    }

    override void render_scene(Viewport viewport) {
        Viewport2D vp = cast(Viewport2D) viewport;
        raylib.BeginMode2D(vp.cam.camera);

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
    }
}
