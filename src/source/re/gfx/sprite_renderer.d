module re.gfx.sprite_renderer;

import re.gfx.sprite;
import re.ng.renderable;
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
        auto tex_rect = raylib.Rectangle(0, 0, sprite.texture.width, sprite.texture.height);
        raylib.DrawTextureRec(sprite.texture, tex_rect, entity.position2, raylib.WHITE);
    }
}