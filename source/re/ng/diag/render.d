module re.ng.diag.render;

import re.core;
import re.ecs;
import re.math;
import re.gfx;
static import raylib;

static class DebugRender {
    public static Color debug_color = Colors.RED;
    public static Color debug_color_2 = Colors.GREEN;

    public static void default_debug_render(Renderable2D renderable) {
        raylib.DrawRectangleLinesEx(renderable.bounds, 1, debug_color);
    }

    public static void default_debug_render(Renderable3D renderable) {
        raylib.DrawBoundingBox(renderable.bounds, debug_color);
    }

    public static void default_debug_render(Renderable3D renderable, Model model) {
        import re.phys.collider;

        default_debug_render(renderable);
        auto comp = cast(Component) renderable;
        raylib.DrawModelWiresEx(model, comp.transform.position, comp.transform.axis_angle.axis,
                comp.transform.axis_angle.angle * C_RAD2DEG, comp.transform.scale, debug_color);

        // check if renderable has colliders
        auto box_colls = comp.entity.get_components!BoxCollider;
        foreach (box; box_colls) {
            auto raw_bounds = BoundingBox( // min
                    Vector3(box.size.x + box.offset.x,
                    box.size.y + box.offset.y, box.size.z + box.offset.z),
                    // max
                    Vector3(box.size.x + box.offset.x, box.size.y + box.offset.y,
                        box.size.z + box.offset.z));
            // transform by entity transform
            auto bounds = Bounds.calculate(raw_bounds, comp.entity.transform);
            // draw transformed bounding box
            raylib.DrawBoundingBox(bounds, debug_color_2);
        }
    }
}
