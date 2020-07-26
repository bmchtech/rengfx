module re.util.tweens.tween;

import re.util.tweens.tween_manager;
import re.util.tweens.ease;

/// represents a tween, to be used for easings/interpolation
class Tween {
    private float* _data;
    public const(float) from;
    public const(float) to;
    public const(float) duration;
    public const(EaseFunction) ease;
    private float elapsed = 0;
    public State state;

    public enum State {
        Running,
        Complete
    }

    this(float* data, float from, float to, float duration, EaseFunction ease) {
        this._data = data;
        this.from = from;
        this.to = to;
        this.duration = duration;
        this.ease = ease;
    }

    public void update(float dt) {
        elapsed += dt;
        // get value from function
        immutable auto v = ease(elapsed, from, to - from, duration);
        // set the value of our data pointer
        *_data = v;
    }
}

@("tween-basic")
unittest {
    import std.math : abs;
    import std.string : format;

    float start = 0;
    float data = start;
    float goal = 1;
    float duration = 1;
    auto tw = new Tween(&data, start, goal, duration, &Ease.EaseLinearNone);
    assert(abs(data - start) < float.epsilon, "tween did not match start");
    tw.update(duration);
    assert(abs(data - goal) < float.epsilon, format("tween did not match goal (was %f)", data));
}
