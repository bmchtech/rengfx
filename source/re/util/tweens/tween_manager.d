module re.util.tweens.tween_manager;

import re.ng.manager;
import re.time;
import re.util.tweens.tween;
import std.algorithm;

/// manages and updates tweens
class TweenManager : Manager {
    /// the tweens being managed (internal)
    private Tween[] _tweens;

    override void update() {
        super.update();

        // update tweens
        Tween[] done;
        foreach (tw; _tweens) {
            tw.update(Time.delta_time);
            if (tw.state == Tween.State.Complete) {
                done ~= tw;
            }
        }
        foreach (tw; done) {
            _tweens = _tweens.remove!(x => x == tw);
        }
    }

    public void register(Tween tw) {
        _tweens ~= tw;
    }
}
