module re.gfx.sprite_renderer;

import re.gfx.sprite;
import re.ng.renderable;
import re.ecs;
import re.ng.position;
static import raylib;

class SpriteRenderer : Component, Renderable {
    private Sprite sprite;

    this(Sprite sprite) {
        this.sprite = sprite;
    }

    public void render() {
        auto pos = entity.get_component!(Position).vec;
        // draw the sprite
        raylib.DrawTexture(sprite.texture, cast(int) pos.x, cast(int) pos.y, raylib.WHITE);
    }
}