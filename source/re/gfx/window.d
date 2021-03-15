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
    public Vector2 scale_dpi;
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
        return cast(int)(_width * scale_dpi.x);
    }

    /// dpi-scaled window height
    @property int height() {
        update_window();
        return cast(int)(_height * scale_dpi.y);
    }

    /// initializes the window
    public void initialize() {
        // create the window
        raylib.InitWindow(_width, _height, "");
        // set options
        raylib.SetTargetFPS(Core.target_fps);
        // get properties
        scale_dpi = raylib.GetWindowScaleDPI();
    }

    public void set_title(string title) {
        raylib.SetWindowTitle(toStringz(title));
    }

    public void resize(int width, int height) {
        raylib.SetWindowSize(width, height);
        update_window();
    }

    private void update_window() {
        _width = raylib.GetScreenWidth();
        _height = raylib.GetScreenHeight();
    }

    public void destroy() {
        raylib.CloseWindow();
    }
}
