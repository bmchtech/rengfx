module re.gfx.sprite_renderer;

import re.gfx.sprite;
import re.ecs;
import re.math;
static import raylib;

class SpriteRenderer : Component, Renderable {
    private Sprite sprite;

    this(Sprite sprite) {
        this.sprite = sprite;
    }

    private Rectangle sprite_tex_rect() {
        pragma(inline, true) return Rectangle(0, 0,
                sprite.texture.width, sprite.texture.height);
    }

    public void render() {
        // draw the sprite
        raylib.DrawTextureRec(sprite.texture, sprite_tex_rect(), entity.position2, raylib.WHITE);
    }

    public void debug_render() {
        auto tex_rec = sprite_tex_rect();
        raylib.DrawRectangleLines(cast(int) entity.position2.x,
                cast(int) entity.position2.y, cast(int) tex_rec.width,
                cast(int) tex_rec.height, raylib.RED);
    }
}
