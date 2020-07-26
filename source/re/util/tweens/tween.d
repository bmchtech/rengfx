module re.util.tweens.tween;

import re.util.tweens.tween_manager;
static import easings;

/// represents a tween, to be used for easings/interpolation
class Tween {
    private float* _data;
    public const(float) from;
    public const(float) to;
    public const(float) duration;
    private float elapsed = 0;
    public State state;

    public enum State {
        Running,
        Complete
    }

    this(float* data, float from, float to, float duration) {
        this._data = data;
        this.from = from;
        this.to = to;
        this.duration = duration;
    }

    public void update(float dt) {
        elapsed += dt;
        // get value from function
        immutable auto v = easings.EaseLinearNone(elapsed, from, to - from, duration);
        // set the value of our data pointer
        *_data = v;
    }
}

@("tween-basic")
unittest {
    import std.math: abs;
    import std.string: format;
    float start = 0;
    float data = start;
    float goal = 1;
    float duration = 1;
    auto tw = new Tween(&data, start, goal, duration);
    assert(abs(data - start) < float.epsilon, "tween did not match start");
    tw.update(duration);
    assert(abs(data - goal) < float.epsilon, format("tween did not match goal (was %f)", data));
}
