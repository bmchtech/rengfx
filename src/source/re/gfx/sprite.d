module re.gfx.sprite;

import re.gfx;
import re.math;

class Sprite {
    public Texture2D texture;
    public Rectangle src_rect;
    public Vector2 origin;

    this(Texture2D texture, Rectangle src_rect, Vector2 origin) {
        this.texture = texture;
        this.src_rect = src_rect;
        this.origin = origin;
    }

    this(Texture2D texture, Rectangle src_rect) {
        this(texture, src_rect, Vector2(src_rect.width / 2, src_rect.height / 2));
    }

    this(Texture2D texture) {
        this(texture, Rectangle(0, 0, texture.width, texture.height));
    }
}
