module re.ng.diag.render;

import re.core;
import re.ecs;
import re.math;
import re.gfx;
static import raylib;

static class DebugRender {
    public static Color debug_color = Colors.RED;
    public static Color debug_color_mesh = Colors.BLACK;
    public static Color debug_color_collider = Colors.GREEN;

    public static void default_debug_render(Renderable2D renderable) {
        import re.math.rectangle_ext;
        import std.algorithm.comparison: max;

        // draw bounding rectangle
        raylib.DrawRectangleLinesEx(renderable.bounds, 1, debug_color);
        // // draw center crosshair
        // auto center = renderable.bounds.center;
        // int crosshair_size = max(cast(int) (Core.default_resolution.x / 200), 1);
        // raylib.DrawLineV(center + Vector2(-crosshair_size, 0), center + Vector2(crosshair_size, 0), debug_color);
        // raylib.DrawLineV(center + Vector2(0, -crosshair_size), center + Vector2(0, crosshair_size), debug_color);
    }

    /// draw 3d bounding box
    private static void draw_bounding_box(BoundingBox raw_box, ref Transform transform, Color color) {
        import std.math : abs;

        auto box = Bounds.calculate(raw_box, transform);

        auto size = Vector3(abs(box.max.x - box.min.x),
            abs(box.max.y - box.min.y), abs(box.max.z - box.min.z));

        auto center = Vector3(box.min.x + size.x / 2.0f, box.min.y + size.y / 2.0f,
            box.min.z + size.z / 2.0f);

        // TODO: we want something that supports transforms

        raylib.DrawCubeWires(center, size.x, size.y, size.z, color);
    }

    // public static void default_debug_render(Renderable3D renderable) {
    //     auto comp = cast(Component) renderable;
    //     draw_bounding_box(renderable.bounds, comp.transform, debug_color);
    // }

    public static void default_debug_render(Renderable3D renderable, Model model) {
        import re.phys.collider;

        // default_debug_render(renderable);
        auto comp = cast(Component) renderable;
        raylib.DrawModelWiresEx(model, comp.transform.position, comp.transform.axis_angle.axis,
            comp.transform.axis_angle.angle * C_RAD2DEG, comp.transform.scale, debug_color_mesh);

        // check if renderable has colliders
        auto box_colls = comp.entity.get_components!BoxCollider;
        foreach (box; box_colls) {
            auto raw_bounds = BoundingBox( // min
                Vector3(-box.size.x + box.offset.x,
                    -box.size.y + box.offset.y, -box.size.z + box.offset.z), // max
                Vector3(box.size.x + box.offset.x, box.size.y + box.offset.y,
                    box.size.z + box.offset.z));
            draw_bounding_box(raw_bounds, comp.entity.transform, debug_color_collider);
        }
    }
}
