module re.gfx.sprite_renderer;

import re.gfx.sprite;
import re.ng.renderable;
import re.ecs;

class SpriteRenderer : Component, Renderable {
    private Sprite sprite;

    this(Sprite sprite) {
        this.sprite = sprite;
    }

    public void render() {
        // draw the sprite
    }
}