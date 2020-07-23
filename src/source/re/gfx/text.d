module re.gfx.text;

import re.ecs;
import re.math;
import re.ng.debugger;
import std.string;
static import raylib;

/// renderable text
class Text : Component, Renderable {
    /// text string
    public string text;
    /// text font
    public raylib.Font font;
    /// font size
    public int size;
    /// text color
    public raylib.Color color;
    private Vector2 _text_size;
    private Vector2 _origin;
    /// default font size
    public enum default_size = 10;
    
    /// create a new text
    this(raylib.Font font, string text, int size, raylib.Color color) {
        this.text = text;
        this.font = font;
        this.size = size;
        this.color = color;
        update_dimens();
    }

    @property Rectangle bounds() {
        return RectangleExt.calculate_bounds(entity.position2, _origin,
                entity.transform.scale2, entity.transform.rotation, _text_size.x, _text_size.y);
    }

    @property private int spacing() {
        return size / default_size;
    }

    /// default font (builtin to raylib)
    @property public static raylib.Font default_font() {
        return raylib.GetFontDefault();
    }

    private void update_dimens() {
        _text_size = raylib.MeasureTextEx(font, toStringz(text), size, spacing);
        // TODO: support centering
        _origin = Vector2(0, 0);
    }

    void render() {
        raylib.DrawTextEx(font, toStringz(text), entity.position2, size, spacing, color);
    }

    void debug_render() {
        Debugger.default_debug_render(this);
    }
}
