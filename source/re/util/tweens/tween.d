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
    void start(bool attach = true);
    void add_chain(ITween[] tw...);
    @property ITween[] get_chain();
    @property void delegate(ITween) callback();
    void set_callback(void delegate(ITween) cb);
}

/// represents a tween, to be used for easings/interpolation
class Tween(T) : ITween {
    alias TRef = T*;
    private TRef[] _datas;
    public const(float[]) from;
    public const(float[]) to;
    public const(float) duration;
    public const(float) delay;
    public const(EaseFunction) ease;
    private ITween[] _chain;
    private float elapsed = 0;
    private TweenState _state;
    private void delegate(ITween) _callback;

    this(TRef[] data, T[] from, T[] to, float duration, EaseFunction ease, float delay = 0) {
        import std.algorithm : map;
        import std.array : array;

        this._datas = data;
        this.from = from.map!(x => cast(float) x).array;
        this.to = to.map!(x => cast(float) x).array;
        this.duration = duration;
        this.ease = ease;
        this.delay = delay;
    }

    @property TweenState state() {
        return _state;
    }

    @property ITween[] get_chain() {
        return _chain;
    }

    @property void delegate(ITween) callback() {
        return _callback;
    }

    public void set_callback(void delegate(ITween) cb) {
        _callback = cb;
    }

    public void update(float dt) {
        if (_state == TweenState.Paused)
            return;

        import std.algorithm.comparison : clamp;

        elapsed += dt;

        // check delay
        if (elapsed < delay)
            return;

        auto run_time = elapsed - delay;

        // clamp the elapsed time (t) value
        auto t = clamp(run_time, 0, duration);

        // - update values
        foreach (i, data; _datas) {
            // get value from function
            immutable auto v = ease(t, from[i], to[i] - from[i], duration);
            // set the value of our data pointer
            *data = cast(T) v;

        }

        if (run_time >= duration) {
            _state = TweenState.Complete;
        }

        // import std.stdio : writefln;

        // writefln("F: %s, T: %s, E: %s, V: %s", from, to, run_time, v);
    }

    public void start(bool attach) {
        _state = TweenState.Running;
        if (attach) {
            import re.core : Core;

            // add tween to global manager
            auto tween_mgr = Core.get_manager!TweenManager;
            assert(!tween_mgr.isNull, "global tween manager not available");
            tween_mgr.get.register(this);
        }
    }

    public void add_chain(ITween[] tw...) {
        _chain ~= tw;
    }
}

/// utility class for starting tweens
class Tweener {
    public static ITween tween(T)(ref T data, T from, T to, float duration,
            EaseFunction ease, float delay = 0) {
        import re.math;

        ITween res;
        static if (is(T == float)) {
            res = new Tween!float([&data], [from], [to], duration, ease, delay);
        } else static if (is(T == int)) {
            res = new Tween!int([&data], [from], [to], duration, ease, delay);
        } else static if (is(T == Color)) {
            res = new Tween!ubyte([&data.r, &data.g, &data.b, &data.a],
                    [from.r, from.g, from.b, from.a], [to.r, to.g, to.b, to.a],
                    duration, ease, delay);
        } else static if (is(T == Vector3)) {
            res = new Tween!float([&data.x, &data.y, &data.z], [
                    from.x, from.y, from.z
                    ], [to.x, to.y, to.z], duration, ease, delay);
        } else {
            assert(0, "tweening this type is not supported");
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
    auto tw = new Tween!float([&data], [start], [goal], duration, &Ease.LinearNone);
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
    auto tw = Tweener.tween(data, start, goal, duration, &Ease.LinearNone, 0);
    tw.start(false); // start, but do not attach
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
    auto tw = Tweener.tween(data, start, goal, duration, &Ease.LinearNone, 0);
    tw.start(false); // start, but do not attach
    // auto tw_r = new Tween!ubyte(&data.r, start.r, goal.r, duration, &Ease.LinearNone);
    // auto tw_g = new Tween!ubyte(&data.g, start.g, goal.g, duration, &Ease.LinearNone);
    // auto tw_b = new Tween!ubyte(&data.b, start.b, goal.b, duration, &Ease.LinearNone);
    // auto tw_a = new Tween!ubyte(&data.a, start.a, goal.a, duration, &Ease.LinearNone);
    assert(data.r == start.r && data.g == start.g && data.b == start.b
            && data.a == start.a, "tween did not match start");
    tw.update(duration);
    // tw_r.update(duration);
    // tw_g.update(duration);
    // tw_b.update(duration);
    // tw_a.update(duration);
    assert(data.r == goal.r && data.g == goal.g && data.b == goal.b
            && data.a == goal.a, format("tween did not match goal (was %f)", data));
}

@("tween-manager")
unittest {
    import re.ng.scene : Scene2D;
    import re.util.test : test_scene;
    import re.math : raymath, Vector2, Vector3;

    auto dest_pos = Vector3(60, 60);
    auto callback_called = false;

    class TestScene : Scene2D {
        override void on_start() {
            auto nt = create_entity("square", Vector2(20, 20));
            auto tw = Tweener.tween(nt.transform.position,
                    nt.transform.position, dest_pos, 0.5f, &Ease.LinearInOut);
            tw.set_callback((tw) { callback_called = true; });
            tw.start();
        }
    }

    auto test = test_scene(new TestScene());
    test.game.run();

    // check conditions
    auto nt = test.scene.get_entity("square");
    assert(raymath.Vector3Length(dest_pos - nt.transform.position) <= float.epsilon,
            "entity did not move to target position");
    assert(callback_called, "callback was not caled");

    test.game.destroy();
}
