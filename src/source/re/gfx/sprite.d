module re.gfx.sprite;

static import raylib;

class Sprite {
    private raylib.Texture2D texture;

    this(raylib.Texture2D texture) {
        this.texture = texture;
    }
}
