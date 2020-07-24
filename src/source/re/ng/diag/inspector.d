module re.ng.diag.inspector;

import re.core;
import re.ecs;
import re.math;
import re.gfx;
import std.conv;
import std.array;
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
    private Vector2 _panel_scroll;
    private InspectedComponent[] _components;

    private class InspectedComponent {
        public Component obj;
        public Class obj_class;
        public string[string] fields;

        this(Component obj) {
            this.obj = obj;
            this.obj_class = obj.getMetaType;
        }

        private void update_fields() {
            foreach (field; obj_class.getFields) {
                string field_name = field.getName;
                string field_value = to!string(field.get(obj));
                this.fields[field_name] = field_value;
            }
        }
    }

    this() {
        reset();
    }

    private void reset() {
        _components = [];
    }

    public void update() {
        // update all inspected components
        foreach (comp; _components) {
            comp.update_fields();
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

        // calculate panel bounds
        // this is going to calculate the space required for each component
        int[] component_section_heights;

        foreach (comp; _components) {
            component_section_heights ~= (header + header_padding) // header
             + ((field_height + field_padding) // field and padding
                     * ((cast(int) comp.fields.length) + 1)); // number of fields
        }
        // total height
        auto panel_bounds_height = component_section_heights.sum();

        auto panel_content_bounds = Rectangle(0, 0, width - pad, panel_bounds_height);

        auto view = raygui.GuiScrollPanel(panel_bounds, panel_content_bounds, &_panel_scroll);
        raylib.BeginScissorMode(cast(int) view.x, cast(int) view.y,
                cast(int) view.width, cast(int) view.height);
        // close button
        auto btn_close = 'x';
        enum btn_close_sz = 12;
        if (raygui.GuiButton(Rectangle(panel_bounds.x + panel_content_bounds.width - pad,
                panel_bounds.y + pad, btn_close_sz, btn_close_sz), &btn_close)) {
            close();
        }
        // - now draw each component section
        auto panel_y_offset = 0; // the offset from the y start of the panel (this is based on component index)
        foreach (i, comp; _components) {
            // layout vars
            auto field_names = comp.fields.keys.sort();
            auto field_index = 0;
            enum field_label_width = 120;
            enum field_value_width = 240;

            // corner for the start of this section
            auto section_corner = Vector2(panel_bounds.x + pad, panel_bounds.y + pad
                    + panel_y_offset);
            // header
            raygui.GuiLabel(Rectangle(section_corner.x, section_corner.y,
                    field_label_width, header), comp.obj_class.getName.c_str());
            // header underline
            raylib.DrawRectangleLinesEx(Rectangle(section_corner.x,
                    section_corner.y + header, panel_bounds.width - pad * 2, 1), 1, Colors.GRAY);
            // list of fields
            foreach (field_name; field_names) {
                auto field_val = comp.fields[field_name];
                // calculate field corner
                auto corner = Vector2(section_corner.x,
                        section_corner.y + (header + header_padding) + field_index * (
                            field_padding + field_height));
                raygui.GuiLabel(Rectangle(corner.x, corner.y,
                        field_label_width, field_height), field_name.c_str());
                raygui.GuiTextBox(Rectangle(corner.x + field_label_width, corner.y,
                        field_value_width, field_height), field_val.c_str(),
                        field_value_width, false);
                field_index++;
            }
            panel_y_offset += component_section_heights[i]; // go to the bottom of this section
        }
        // raygui.GuiGrid(Rectangle(panel_bounds.x + _panel_scroll.x, panel_bounds.y + _panel_scroll.y,
        //         panel_content_bounds.width, panel_content_bounds.height), 16, 4);
        raylib.EndScissorMode();
    }

    /// attach the inspector to an object
    public void inspect(Entity nt) {
        assert(_components.length == 0, "only one inspector may be open at a time");
        open = true;
        // add components
        _components ~= nt.get_all_components.map!(x => new InspectedComponent(x)).array;
    }

    /// close the inspector
    public void close() {
        assert(open, "inspector is already closed");
        open = false;
        reset();
    }
}
