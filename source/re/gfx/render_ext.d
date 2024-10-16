/** rendering extensions and utilities */

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

    /// draws a render target to the specified destination rect, tinted with color, supporting a subregion of the input texture
    public static void draw_render_target_crop(RenderTarget target, Rectangle source_rect, Rectangle dest_rect, Color color) {
        if (source_rect == RectangleZero) {
            // default to full texture
            source_rect = Rectangle(0, 0, target.texture.width, target.texture.height);
        }
        // negate height to ensure orientation is correct
        source_rect.height = -source_rect.height;
        // import std.stdio;
        // writefln("target texture size: (%s, %s)", target.texture.width, target.texture.height);
        // writefln("source rect: (%s, %s, %s, %s)", source_rect.x, source_rect.y, source_rect.width, source_rect.height);
        // writefln("dest rect: (%s, %s, %s, %s)", dest_rect.x, dest_rect.y, dest_rect.width, dest_rect.height);
        raylib.DrawTexturePro(target.texture, source_rect, dest_rect, Vector2(0, 0), 0, color);
    }

    /// draws a render target on another with an effect
    public static void draw_render_target_from(RenderTarget source, RenderTarget dest, Effect effect) {
        auto dest_rect = Rectangle(0, 0, dest.texture.width, dest.texture.height);
        // start drawing on dest
        raylib.BeginTextureMode(dest);
        // with shader
        raylib.BeginShaderMode(effect.shader);
        // blit our render target
        draw_render_target(source, dest_rect, effect.color);
        raylib.EndShaderMode();
        raylib.EndTextureMode();
    }

    /// draws a render target on another with an effect
    public static void draw_render_target_from(RenderTarget source, RenderTarget dest) {
        auto dest_rect = Rectangle(0, 0, dest.texture.width, dest.texture.height);
        // start drawing on dest
        raylib.BeginTextureMode(dest);
        // blit our render target
        draw_render_target(source, dest_rect, Colors.WHITE);
        raylib.EndTextureMode();
    }

    /// create render target with a given size
    public static RenderTarget create_render_target(int width, int height) {
        return raylib.LoadRenderTexture(width, height);
    }

    /// destroy render target
    public static void destroy_render_target(RenderTarget target) {
        raylib.UnloadRenderTexture(target);
    }
}
