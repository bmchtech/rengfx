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

    public void render() {
        // draw the sprite
        raylib.DrawTextureRec(sprite.texture, sprite.src_rect, entity.position2, raylib.WHITE);
    }

    public void debug_render() {
        raylib.DrawRectangleLines(cast(int) entity.position2.x,
                cast(int) entity.position2.y, cast(int) sprite.src_rect.width,
                cast(int) sprite.src_rect.height, raylib.RED);
    }
}
