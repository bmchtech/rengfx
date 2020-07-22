module re.gfx.window;

import std.string;
static import raylib;

class Window {
    private int width;
    private int height;

    this(int width, int height) {
        this.width = width;
        this.height = height;
    }

    public void initialize() {
        // create the window
        raylib.InitWindow(width, height, "");
        // set options
        raylib.SetTargetFPS(60);
    }

    public void set_title(string title) {
        // TODO: set window title
        raylib.SetWindowTitle(toStringz(title));
    }

    public void destroy() {
        raylib.CloseWindow();
    }
}
