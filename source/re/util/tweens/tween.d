module re.util.tweens.tween;

import re.util.tweens.tween_manager;
import re.util.tweens.ease;

public enum TweenState {
    Running,
    Complete
}

interface ITween {
    @property TweenState state();
    void update(float dt);
}

/// represents a tween, to be used for easings/interpolation
class Tween(T) : ITween {
    private T* _data;
    public const(float) from;
    public const(float) to;
    public const(float) duration;
    public const(EaseFunction) ease;
    private float elapsed = 0;
    private TweenState _state;

    this(T* data, T from, T to, float duration, EaseFunction ease) {
        this._data = data;
        this.from = cast(float) from;
        this.to = cast(float) to;
        this.duration = duration;
        this.ease = ease;
    }

    @property TweenState state() {
        return _state;
    }

    public void update(float dt) {
        elapsed += dt;
        // get value from function
        immutable auto v = ease(elapsed, from, to - from, duration);
        // set the value of our data pointer
        *_data = cast(T) v;
        if (elapsed >= duration) {
            _state = TweenState.Complete;
        }
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
    auto tw = new Tween!float(&data, start, goal, duration, &Ease.EaseLinearNone);
    assert(abs(data - start) < float.epsilon, "tween did not match start");
    tw.update(duration);
    assert(abs(data - goal) < float.epsilon, format("tween did not match goal (was %f)", data));
    assert(tw.state == TweenState.Complete);
}

@("tween-int")
unittest {
    import std.string : format;

    int start = 0;
    int data = start;
    int goal = 100;
    float duration = 1;
    auto tw = new Tween!int(&data, start, goal, duration, &Ease.EaseLinearNone);
    assert(data == start, "tween did not match start");
    tw.update(duration);
    assert(data == goal, format("tween did not match goal (was %f)", data));
}
