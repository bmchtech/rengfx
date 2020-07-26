module re.ng.diag.render;

import re.core;
import re.ecs;
import re.math;
import re.gfx;
static import raylib;

static class DebugRender {
    public static Color debug_color = Colors.RED;

    public static void default_debug_render(Renderable2D renderable) {
        raylib.DrawRectangleLinesEx(renderable.bounds, 1, debug_color);
    }

    public static void default_debug_render(Renderable3D renderable) {
        raylib.DrawBoundingBox(renderable.bounds, debug_color);
    }

    public static void default_debug_render(Renderable3D renderable, Model model) {
        default_debug_render(renderable);
        auto comp = cast(Component) renderable;
        raylib.DrawModelWires(model, comp.entity.position,
                comp.entity.transform.scale.x, debug_color);
    }
}
