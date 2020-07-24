module re.ng.diag.inspector;

import re.core;
import re.ecs;
import re.math;
import re.gfx;
import std.conv;
import std.algorithm;
import std.string;
import re.util.interop;
import witchcraft;
static import raylib;
static import raygui;

/// real-time object inspector
class Inspector {
    /// panel width
    enum width = 400;
    /// whether the inspector is open
    public bool open = false;
    private Component _obj;
    private Class _obj_class;
    private string[string] _fields;
    private Vector2 _panel_scroll;

    this() {
        reset();
    }

    private void reset() {
        _obj = null;
        _fields.clear();
    }

    public void update() {
        // update fields
        foreach (field; _obj_class.getFields) {
            _fields[field.getName] = to!string(field.get(_obj));
        }
    }

    public void render() {
        alias pad = Core.debugger.screen_padding;
        auto panel_bounds = Rectangle(pad, pad, width, Core.window.height - pad * 2);
        // draw indicator of panel bounds
        // raylib.DrawRectangleRec(panel_bounds, Colors.GRAY);

        // calculate panel content size
        enum field_height = 16;
        enum field_padding = 2;
        enum header = field_height;
        enum header_padding = 4;
        auto panel_content_bounds = Rectangle(0, 0, width - pad,
                (header + header_padding) + (field_height + field_padding) * (_fields.length + 1));

        auto view = raygui.GuiScrollPanel(panel_bounds, panel_content_bounds, &_panel_scroll);
        raylib.BeginScissorMode(cast(int) view.x, cast(int) view.y,
                cast(int) view.width, cast(int) view.height);
        auto field_names = _fields.keys.sort();
        auto field_index = 0;
        enum field_label_width = 120;
        enum field_value_width = 240;
        auto panel_corner = Vector2(panel_bounds.x + pad, panel_bounds.y + pad);
        raygui.GuiLabel(Rectangle(panel_corner.x, panel_corner.y,
                field_label_width, header), _obj_class.getName.c_str());
        raylib.DrawRectangleLinesEx(Rectangle(panel_corner.x,
                panel_corner.y + header, panel_bounds.width - pad * 2, 1), 1, Colors.GRAY);
        foreach (field_name; field_names) {
            auto field_val = _fields[field_name];
            // calculate field corner
            auto corner = Vector2(panel_corner.x,
                    panel_corner.y + (header + header_padding) + field_index * (
                        field_padding + field_height));
            raygui.GuiLabel(Rectangle(corner.x, corner.y, field_label_width,
                    field_height), field_name.c_str());
            raygui.GuiTextBox(Rectangle(corner.x + field_label_width, corner.y,
                    field_value_width, field_height), field_val.c_str(), field_value_width, false);
            field_index++;
        }
        // raygui.GuiGrid(Rectangle(panel_bounds.x + _panel_scroll.x, panel_bounds.y + _panel_scroll.y,
        //         panel_content_bounds.width, panel_content_bounds.height), 16, 4);
        raylib.EndScissorMode();
    }

    /// attach the inspector to an object
    public void inspect(Component obj) {
        assert(_obj is null, "only one inspector may be open at a time");
        open = true;
        _obj = obj;
        _obj_class = _obj.getMetaType;
    }

    /// close the inspector
    public void close() {
        assert(open, "inspector is already closed");
        open = false;
        reset();
    }
}
