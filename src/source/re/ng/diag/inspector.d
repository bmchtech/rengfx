module re.ng.diag.inspector;

import re.core;
import re.ecs;
import re.math;
import re.gfx;
import std.conv;
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
        raylib.DrawRectangleRec(Rectangle(pad, pad, width,
                Core.window.height - pad * 2), Color(100, 100, 100, 100));
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
