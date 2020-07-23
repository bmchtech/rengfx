module re.gfx.text;

import re.ecs;
import re.math;
import re.ng.debugger;
import std.string;
static import raylib;

class Text : Component, Renderable {
    public string text;
    public raylib.Font font;
    public int size;
    public raylib.Color color;
    private Vector2 _text_size;
    private Vector2 _origin;
    public enum default_size = 10;

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
