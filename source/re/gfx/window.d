/** system window */

module re.gfx.window;

import re.core;
import re.math;
import std.string;
import std.algorithm.comparison : max;
static import raylib;

class Window {
    /// whether window has been created
    private bool _created = false;
    /// flags
    private uint _window_flags;
    /// properties
    private bool _resizable;

    /// initializes the window
    public void initialize(int width, int height) {
        // set config flags
        // tell raylib we're hidpi aware
        _window_flags |= raylib.ConfigFlags.FLAG_WINDOW_HIGHDPI;
        raylib.SetConfigFlags(_window_flags);

        // create the window
        raylib.InitWindow(width, height, "");
        _created = true; // window has been created

        // set options
        raylib.SetTargetFPS(Core.target_fps);
    }

    public void set_resizable(bool resizable) {
        _resizable = resizable;
        if (_created) {
            // fail, you can't set resizable after window creation
            Core.log.error("Window.set_resizable: cannot set resizable after window creation");
            assert(false);
        }
        if (resizable) {
            _window_flags |= raylib.ConfigFlags.FLAG_WINDOW_RESIZABLE;
        } else {
            _window_flags &= ~raylib.ConfigFlags.FLAG_WINDOW_RESIZABLE;
        }
    }

    public void destroy() {
        raylib.CloseWindow();
    }

    public @property float dpi_scale() {
        auto scale_dpi_vec = raylib.GetWindowScaleDPI();
        return max(scale_dpi_vec.x, scale_dpi_vec.y);
    }

    public @property int screen_width() {
        return raylib.GetScreenWidth();
    }

    public @property int screen_height() {
        return raylib.GetScreenHeight();
    }

    public @property int render_width() {
        return raylib.GetRenderWidth();
    }

    public @property int render_height() {
        return raylib.GetRenderHeight();
    }

    public @property bool is_minimized() {
        return raylib.IsWindowMinimized();
    }

    public @property bool is_maximized() {
        return raylib.IsWindowMaximized();
    }

    public @property bool is_focused() {
        return raylib.IsWindowFocused();
    }

    public @property bool is_resized() {
        return raylib.IsWindowResized();
    }

    public void set_icon(raylib.Image image) {
        raylib.SetWindowIcon(image);
    }

    public void resize(int width, int height) {
        raylib.SetWindowSize(width, height);
    }

    public void set_position(int x, int y) {
        raylib.SetWindowPosition(x, y);
    }

    public void set_title(string title) {
        raylib.SetWindowTitle(title.toStringz);
    }

    public void toggle_fullscreen() {
        raylib.ToggleFullscreen();
    }

    public void toggle_borderless_windowed() {
        raylib.ToggleBorderlessWindowed();
    }

    public void maximize() {
        raylib.MaximizeWindow();
    }

    public void minimize() {
        raylib.MinimizeWindow();
    }

    public void restore() {
        raylib.RestoreWindow();
    }

    public void set_focused() {
        raylib.SetWindowFocused();
    }
}
