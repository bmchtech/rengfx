module re.gfx.sprite_renderer;

import re.gfx;
import re.ecs;
import re.math;
import re.ng.diag;
static import raylib;

class SpriteRenderer : Component, Renderable2D {
    /// the sprite
    public Sprite sprite;
    /// color tint
    public Color color = Colors.WHITE;

    this(Sprite sprite) {
        this.sprite = sprite;
    }

    @property Rectangle bounds() {
        return Bounds.calculate(entity.transform, sprite.origin, sprite.src_rect.width, sprite.src_rect.height);
    }

    public void render() {
        // draw the sprite
        auto dest_rect = Rectangle(entity.position2.x, entity.position2.y,
                sprite.src_rect.width, sprite.src_rect.height);
        raylib.DrawTexturePro(sprite.texture, sprite.src_rect, dest_rect,
                sprite.origin, entity.transform.rotation_z * C_RAD2DEG, color);
    }

    public void debug_render() {
        DebugRender.default_debug_render(this);
    }
}
