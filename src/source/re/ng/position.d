module re.ng.position;
static import raylib;

class Position {
    public raylib.Vector2 vec;

    this(float x, float y) {
        vec = raylib.Vector2(x, y);
    }
}