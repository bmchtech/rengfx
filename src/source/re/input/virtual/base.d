module re.input.virtual.base;

import re.input;
import std.algorithm;

/// method of resolving conflicting, overlapping inputs
enum OverlapBehavior {
    Cancel,
    Older,
    Newer
}

/// a virtual input composed of input node units
abstract class VirtualInput {
    public Node[] nodes;

    this() {
        Input.virtual_inputs ~= this;
    }

    public void destroy() {
        Input.virtual_inputs = Input.virtual_inputs.remove!(x => x == this);
    }

    public void update() {
        foreach (node; nodes) {
            node.update();
        }
    }

    /// monitors a single unit for input
    static abstract class Node {
        void update() {
        }
    }
}
