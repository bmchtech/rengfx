module re.math.rect;

struct RectangleInt {
    int x, y, w, h;

    this(int x, int y, int w, int h) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }
}