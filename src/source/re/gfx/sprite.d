module re.gfx.sprite;

import re.gfx;
import re.math;

class Sprite {
    public Texture2D texture;
    public Rectangle src_rect;

    this(Texture2D texture, Rectangle src_rect) {
        this.texture = texture;
        this.src_rect = src_rect;
    }

    this(Texture2D texture) {
        this(texture, Rectangle(0, 0, texture.width, texture.height));
    }
}
