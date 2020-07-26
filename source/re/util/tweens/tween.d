module re.util.tweens.tween;

import re.util.tweens.tween_manager;
import re.util.tweens.ease;
import re.gfx.raytypes;

public enum TweenState {
    Running,
    Paused,
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
        if (_state == TweenState.Paused)
            return;

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

/// utility class for starting tweens
class Tweener {
    public static ITween[] tween(T)(ref T data, T from, T to, float duration,
            EaseFunction ease, bool attach = true) {
        import re.core : Core;

        ITween[] res;
        static if (is(T == float)) {
            res ~= [new Tween!float(&data, from, to, duration, ease)];
        } else static if (is(T == int)) {
            res ~= [new Tween!int(&data, from, to, duration, ease)];
        } else static if (is(T == Color)) {
            res ~= [
                new Tween!ubyte(&data.r, from.r, to.r, duration, ease),
                new Tween!ubyte(&data.g, from.g, to.g, duration, ease),
                new Tween!ubyte(&data.b, from.b, to.b, duration, ease),
                new Tween!ubyte(&data.a, from.a, to.a, duration, ease),
            ];
        } else {
            assert(0, "tweening this type is not supported");
        }
        if (attach) {
            // add tweens to global manager
            foreach (tw; res) {
                Core.get_manager!TweenManager.register(tw);
            }
        }
        return res;
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
    auto tw = Tweener.tween(data, start, goal, duration, &Ease.EaseLinearNone, false)[0];
    assert(data == start, "tween did not match start");
    tw.update(duration);
    assert(data == goal, format("tween did not match goal (was %f)", data));
}

@("tween-color")
unittest {
    import std.string : format;

    Color start = Colors.BLACK;
    Color data = start;
    Color goal = Colors.RAYWHITE;
    float duration = 1;
    auto tweens = Tweener.tween(data, start, goal, duration, &Ease.EaseLinearNone, false);
    // auto tw_r = new Tween!ubyte(&data.r, start.r, goal.r, duration, &Ease.EaseLinearNone);
    // auto tw_g = new Tween!ubyte(&data.g, start.g, goal.g, duration, &Ease.EaseLinearNone);
    // auto tw_b = new Tween!ubyte(&data.b, start.b, goal.b, duration, &Ease.EaseLinearNone);
    // auto tw_a = new Tween!ubyte(&data.a, start.a, goal.a, duration, &Ease.EaseLinearNone);
    assert(data.r == start.r && data.g == start.g && data.b == start.b
            && data.a == start.a, "tween did not match start");
    foreach (tw; tweens) {
        tw.update(duration);
    }
    // tw_r.update(duration);
    // tw_g.update(duration);
    // tw_b.update(duration);
    // tw_a.update(duration);
    assert(data.r == goal.r && data.g == goal.g && data.b == goal.b
            && data.a == goal.a, format("tween did not match goal (was %f)", data));
}
