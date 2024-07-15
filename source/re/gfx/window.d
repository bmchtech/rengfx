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
    // raw window width and height
    private int _width;
    private int _height;
    /// the window dpi scale
    private float _scale_dpi;
    /// the monitor
    private int _monitor;
    /// flags
    private uint _window_flags;
    /// properties
    private bool _resizable;

    /// creates a window instance with the given dimensions
    this(int width, int height) {
        _width = width;
        _height = height;
    }

    /// window width
    @property int width() {
        update_window();
        return cast(int)(_width);
    }

    /// window height
    @property int height() {
        update_window();
        return cast(int)(_height);
    }

    @property float scale_dpi() {
        update_window();
        return _scale_dpi;
    }

    // window dpi-scaled width
    @property int width_dpi() {
        return cast(int)(width * scale_dpi);
    }

    // window dpi-scaled height
    @property int height_dpi() {
        return cast(int)(height * scale_dpi);
    }

    /// initializes the window
    public void initialize() {
        // set config flags
        // tell raylib we're hidpi aware
        _window_flags |= raylib.ConfigFlags.FLAG_WINDOW_HIGHDPI;
        raylib.SetConfigFlags(_window_flags);

        // create the window
        raylib.InitWindow(_width, _height, "");
        _created = true; // window has been created

        // set options
        raylib.SetTargetFPS(Core.target_fps);
        // // get properties
        // _scale_dpi = get_display_dpi_scale();
        update_window();
    }

    public static float get_display_dpi_scale() {
        auto scale_dpi_vec = raylib.GetWindowScaleDPI();
        return max(scale_dpi_vec.x, scale_dpi_vec.y);
    }

    public void set_title(string title) {
        raylib.SetWindowTitle(toStringz(title));
    }

    public void resize(int width, int height) {
        raylib.SetWindowSize(width, height);
        update_window();
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

    private void update_window() {
        _width = raylib.GetScreenWidth();
        _height = raylib.GetScreenHeight();
        _scale_dpi = get_display_dpi_scale();
    }

    public void destroy() {
        raylib.CloseWindow();
    }
}
