module re.gfx.render_ext;

import re.math;
import re.gfx;
static import raylib;

/// renderer utilities
static class RenderExt {
    /// draws a render target to the specified destination rect, tinted with color
    public static void draw_render_target(RenderTarget target, Rectangle dest_rect, Color color) {
        raylib.DrawTexturePro(target.texture, Rectangle(0, 0,
                target.texture.width, -target.texture.height), dest_rect, Vector2(0, 0), 0, color);
    }

    /// draws a render target on another with an effect
    public static void draw_render_target_from(RenderTarget source, RenderTarget dest, Effect effect) {
        auto dest_rect = Rectangle(0, 0,
                dest.texture.width, dest.texture.height);
        // start drawing on dest
        raylib.BeginTextureMode(dest);
        // with shader
        raylib.BeginShaderMode(effect.shader);
        // blit our render target
        draw_render_target(source, dest_rect, effect.color);
        raylib.EndShaderMode();
        raylib.EndTextureMode();
    }
}
