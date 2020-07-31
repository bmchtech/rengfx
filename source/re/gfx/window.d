module re.gfx.window;

import re.core;
import re.math;
import std.string;
static import raylib;

class Window {
    // raw window width and height
    private int _width;
    private int _height;
    /// the window dpi scale
    public Vector2 dpi;
    /// the monitor
    private int _monitor;

    /// creates a window instance with the given dimensions
    this(int width, int height) {
        _width = width;
        _height = height;
    }

    /// dpi-scaled window width
    @property int width() {
        update_window();
        return cast(int)(_width * dpi.x);
    }

    /// dpi-scaled window height
    @property int height() {
        update_window();
        return cast(int)(_height * dpi.y);
    }

    /// initializes the window
    public void initialize() {
        // create the window
        raylib.InitWindow(_width, _height, "");
        // set options
        raylib.SetTargetFPS(Core.target_fps);
        // get properties
        dpi = raylib.GetWindowScaleDPI();
    }

    public void set_title(string title) {
        // TODO: set window title
        raylib.SetWindowTitle(toStringz(title));
    }

    private void update_window() {
        _width = raylib.GetScreenWidth();
        _height = raylib.GetScreenHeight();
    }

    public void destroy() {
        raylib.CloseWindow();
    }
}
