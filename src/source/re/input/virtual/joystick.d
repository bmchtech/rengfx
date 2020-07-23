module re.input.virtual.joystick;

import re.input;
import re.math;
import std.algorithm;

/// a virtual joystick
class VirtualJoystick : VirtualInput {
    // monitors four of inputs to make a joystick
    static abstract class Node : VirtualInput.Node {
        @property public Vector2 value();
    }

    /// logic-controllable joystick
    static class LogicJoystick : Node {
        public Vector2 logic_value;

        @property public override Vector2 value() {
            return logic_value;
        }
    }

    /// monitors a pair of keyboard keys
    static class KeyboardKeys : Node {
        public OverlapBehavior overlap_behavior;
        public Keys left;
        public Keys right;
        public Keys up;
        public Keys down;
        private Vector2 _value;
        private bool _turned_x;
        private bool _turned_y;

        /// creates a keyboard keys node
        this(Keys left, Keys right, Keys up, Keys down,
                OverlapBehavior overlap_behavior = OverlapBehavior.init) {
            this.left = left;
            this.right = right;
            this.up = up;
            this.down = down;
            this.overlap_behavior = overlap_behavior;
        }

        @property public override Vector2 value() {
            return _value;
        }

        public override void update() {
            // x axis
            if (Input.is_key_down(left)) {
                if (Input.is_key_down(right)) {
                    switch (overlap_behavior) {
                    case OverlapBehavior.Cancel:
                        _value.x = 0;
                        break;
                    case OverlapBehavior.Newer:
                        if (!_turned_x) {
                            _value.x *= -1;
                            _turned_x = true;
                        }
                        break;
                    case OverlapBehavior.Older:
                        break; // we don't touch the value
                    default:
                        assert(0);
                    }
                } else {
                    _turned_x = false;
                    _value.x = 1;
                }
            } else if (Input.is_key_down(right)) {
                _turned_x = false;
                _value.x = -1;
            } else {
                _turned_x = false;
                _value.x = 0;
            }
            // y axis
            if (Input.is_key_down(up)) {
                if (Input.is_key_down(down)) {
                    switch (overlap_behavior) {
                    case OverlapBehavior.Cancel:
                        _value.y = 0;
                        break;
                    case OverlapBehavior.Newer:
                        if (!_turned_y) {
                            _value.y *= -1;
                            _turned_y = true;
                        }
                        break;
                    case OverlapBehavior.Older:
                        break; // we don't touch the value
                    default:
                        assert(0);
                    }
                } else {
                    _turned_y = false;
                    _value.y = 1;
                }
            } else if (Input.is_key_down(down)) {
                _turned_y = false;
                _value.y = -1;
            } else {
                _turned_y = false;
                _value.y = 0;
            }
        }
    }

    @property public Vector2 value() {
        foreach (node; nodes) {
            auto val = (cast(Node) node).value;
            if (val != raymath.Vector2Zero()) {
                return val;
            }
        }
        return raymath.Vector2Zero();
    }
}

unittest {
    auto the_joy = new VirtualJoystick();
    the_joy.nodes ~= new VirtualJoystick.KeyboardKeys(Keys.KEY_LEFT,
            Keys.KEY_RIGHT, Keys.KEY_UP, Keys.KEY_DOWN);

    assert(the_joy.nodes.length > 0);
}
