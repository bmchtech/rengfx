module re.util.tweens.tween_manager;

import re.ng.manager;
import re.time;
import re.util.tweens.tween;
import std.algorithm;

/// manages and updates tweens
class TweenManager : Manager {
    /// the tweens being managed (internal)
    private ITween[] _tweens;
    private uint _update_count;

    override void update() {
        super.update();
        _update_count++;
        import std.stdio : writefln;

        writefln("beans: %s", _update_count);

        // update tweens
        ITween[] done;
        foreach (tw; _tweens) {
            tw.update(Time.delta_time);
            if (tw.state == TweenState.Complete) {
                done ~= tw;
            }
        }
        foreach (tw; done) {
            // remove from our tween list
            _tweens = _tweens.remove!(x => x == tw);
            // add chains to our list
            _tweens ~= tw.get_chain;
            // call callback
            auto cb = tw.callback;
            cb(tw);
        }
    }

    public void register(ITween tw) {
        _tweens ~= tw;
    }
}
