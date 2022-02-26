/** basc sprites as texture regions */

module re.gfx.sprite;

import re.gfx;
import re.math;

/// represents a drawable texture region
class Sprite {
    /// raw texture data
    public Texture2D texture;
    /// texture region
    public Rectangle src_rect;
    /// origin point (for rotation and position)
    public Vector2 origin;

    /// creates a sprite given a region and origin
    this(Texture2D texture, Rectangle src_rect, Vector2 origin) {
        this.texture = texture;
        this.src_rect = src_rect;
        this.origin = origin;
    }

    /// creates a sprite given a region
    this(Texture2D texture, Rectangle src_rect) {
        this(texture, src_rect, Vector2(src_rect.width / 2, src_rect.height / 2));
    }

    /// creates a sprite
    this(Texture2D texture) {
        this(texture, Rectangle(0, 0, texture.width, texture.height));
    }
}
