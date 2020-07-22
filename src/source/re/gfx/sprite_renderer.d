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
        auto dest_rect = Rectangle(entity.position2.x, entity.position2.y, sprite.src_rect.width, sprite.src_rect.height);
        raylib.DrawTexturePro(sprite.texture, sprite.src_rect, dest_rect, sprite.origin, entity.rotation, raylib.WHITE);
    }

    public void debug_render() {
        raylib.DrawRectangleLines(cast(int) entity.position2.x,
                cast(int) entity.position2.y, cast(int) sprite.src_rect.width,
                cast(int) sprite.src_rect.height, raylib.RED);
    }
}
