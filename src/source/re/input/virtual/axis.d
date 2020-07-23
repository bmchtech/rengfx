module re.input.virtual.axis;

import re.input;
import std.algorithm;

/// a virtual axis
class VirtualAxis : VirtualInput {
    /// monitors a pair of inputs to make an axis
    static abstract class Node : VirtualInput.Node {
        @property public float value();
    }

    /// logic-controllable axis
    static class LogicAxis : Node {
        public float logic_value;

        @property public override float value() {
            return logic_value;
        }
    }

    /// monitors a pair of keyboard keys
    static class KeyboardKeys : Node {
        public OverlapBehavior overlap_behavior;
        public Keys positive;
        public Keys negative;
        private float _value;
        private bool _turned;

        /// creates a keyboard keys node
        this(Keys positive, Keys negative, OverlapBehavior overlap_behavior = OverlapBehavior.init) {
            this.positive = positive;
            this.negative = negative;
            this.overlap_behavior = overlap_behavior;
        }

        @property public override float value() {
            return _value;
        }

        public override void update() {
            if (Input.is_key_down(positive)) {
                if (Input.is_key_down(negative)) {
                    switch (overlap_behavior) {
                    case OverlapBehavior.Cancel:
                        _value = 0;
                        break;
                    case OverlapBehavior.Newer:
                        if (!_turned) {
                            _value *= -1;
                            _turned = true;
                        }
                        break;
                    case OverlapBehavior.Older:
                        break; // we don't touch the value
                    default:
                        assert(0);
                    }
                } else {
                    _turned = false;
                    _value = 1;
                }
            } else if (Input.is_key_down(negative)) {
                _turned = false;
                _value = -1;
            } else {
                _turned = false;
                _value = 0;
            }
        }
    }

    @property public float value() {
        foreach (node; nodes) {
            auto val = (cast(Node) node).value;
            if (val != 0) {
                return val;
            }
        }
        return 0;
    }
}

unittest {
    auto the_axis = new VirtualAxis();
    the_axis.nodes ~= new VirtualAxis.KeyboardKeys(Keys.KEY_LEFT, Keys.KEY_RIGHT);

    assert(the_axis.nodes.length > 0);
}
