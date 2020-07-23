module re.input.virtual.axis;

import re.input;
import std.algorithm;

/// a virtual axis
class VirtualAxis : VirtualInput {
    static abstract class Node : VirtualInput.Node {
    }
}

unittest {
    auto the_axis = new VirtualAxis();
    the_axis.nodes ~= new VirtualAxis.KeyboardKeys(Keys.KEY_LEFT, Keys.KEY_RIGHT);

    assert(the_axis.nodes.length > 0);
}
