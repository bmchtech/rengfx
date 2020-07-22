module re.gfx.sprite;

static import raylib;

class Sprite {
    public raylib.Texture2D texture;

    this(raylib.Texture2D texture) {
        this.texture = texture;
    }
}
