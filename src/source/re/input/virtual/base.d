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
    /// the input node units
    public Node[] nodes;

    /// create and register a virtual input
    this() {
        Input.virtual_inputs ~= this;
    }

    /// unregister from virtual input updates
    public void unregister() {
        Input.virtual_inputs = Input.virtual_inputs.remove!(x => x == this);
    }

    /// updates all nodes
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

unittest {
    import re.ecs;
    import std.algorithm;

    class InputComponent : Component {
        public VirtualButton bonk;

        this() {
            bonk = new VirtualButton();
            bonk.nodes ~= new VirtualButton.LogicButton();
        }

        override void destroy() {
            bonk.unregister();
        }
    }

    auto ecs = new EntityManager();
    auto nt = ecs.create_entity();
    auto controls = new InputComponent();
    nt.add_component(controls);
    // make sure input is registered
    assert(Input.virtual_inputs.any!(x => x == controls.bonk));
    assert(nt.has_component!InputComponent);
    ecs.destroy();
    // make sure entity was deactivated
    assert(!nt.alive);
    // make sure input is unregistered
    assert(!Input.virtual_inputs.any!(x => x == controls.bonk));
}
