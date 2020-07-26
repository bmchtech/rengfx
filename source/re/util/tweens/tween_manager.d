module re.util.tweens.tween_manager;

import re.ng.manager;
import re.time;
import re.util.tweens.tween;
import std.algorithm;

/// manages and updates tweens
class TweenManager : Manager {
    /// the tweens being managed (internal)
    private ITween[] _tweens;

    override void update() {
        super.update();

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
        }
    }

    public void register(ITween tw) {
        _tweens ~= tw;
    }
}
