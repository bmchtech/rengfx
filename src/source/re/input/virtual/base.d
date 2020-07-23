module re.input.virtual.base;

import re.input;

/// a virtual input composed of input node units
abstract class VirtualInput {
    public Node[] nodes;

    /// monitors a single unit for input
    static abstract class Node {
    }
}
