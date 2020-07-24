module re.ng.render_ext;

import re.math;
import re.gfx;
static import raylib;

static class RenderExt {
    public static void draw_render_target(ref raylib.RenderTexture2D target,
            Rectangle dest_rect, Color color) {
        raylib.DrawTexturePro(target.texture, Rectangle(0, 0, target.texture.width, -target.texture.height),
                dest_rect, Vector2(0, 0), 0, color);
    }
}
