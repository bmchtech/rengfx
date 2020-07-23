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
    private Align _horiz_align;
    private Align _vert_align;

    /// alignment style
    public enum Align {
        /// left or top
        Close,
        /// center
        Center,
        /// right or bottom
        Far
    }

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
        // calculate origin
        auto ori_x = 0.0;
        auto ori_y = 0.0;
        if (_horiz_align == Align.Close)
            ori_x = 0;
        else if (_horiz_align == Align.Center)
            ori_x = _text_size.x / 2;
        else
            ori_x = _text_size.x;
        if (_vert_align == Align.Close)
            ori_y = 0;
        else if (_vert_align == Align.Center)
            ori_y = _text_size.y / 2;
        else
            ori_y = _text_size.y;
        _origin = Vector2(ori_x, ori_y);
    }

    public void set_align(Align horiz, Align vert) {
        _horiz_align = horiz;
        _vert_align = vert;
    }

    void render() {
        raylib.DrawTextEx(font, toStringz(text), entity.position2, size, spacing, color);
    }

    void debug_render() {
        Debugger.default_debug_render(this);
    }
}
