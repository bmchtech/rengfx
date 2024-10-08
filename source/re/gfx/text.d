/** renderable text */

module re.gfx.text;

import re.ecs;
import re.math;
import re.ng.diag;
import std.string;
static import raylib;

/// renderable text
class Text : Component, Renderable2D {
    private string _text;
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
        import re.core : Core;

        this._text = text;
        this.font = font;
        this.size = size;
        this.color = color;
        update_dimens();

        raylib.SetTextureFilter(font.texture, Core.default_filter_mode);
    }

    /// gets text string
    @property string text() {
        return _text;
    }

    /// sets text string
    @property string text(string value) {
        _text = value;
        update_dimens();
        return value;
    }

    @property Rectangle bounds() {
        return Bounds.calculate(entity.transform, _origin, _text_size.x, _text_size.y);
    }

    @property private int spacing() {
        return size / default_size;
    }

    /// default font (builtin to raylib)
    @property public static raylib.Font default_font() {
        return raylib.GetFontDefault();
    }

    private void update_dimens() {
        _text_size = raylib.MeasureTextEx(font, toStringz(_text), size, spacing);
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
        update_dimens();
    }

    void render() {
        raylib.DrawTextEx(font, toStringz(_text), entity.position2 - _origin, size, spacing, color);
    }

    void debug_render() {
        DebugRender.default_debug_render(this);
    }
}
