/**
    The main package of RE ENGINE FX.
    
    Includes Core, Scene, Input, ECS, Tweens, Logger, and some utilities.

    Core is the most important place to start, as it provides access to all key features.
*/

module re;

public {
    // core engine
    import re.core;
    import re.ng.scene;

    // input
    import re.input;

    // ecs
    import re.ecs;

    // util
    import re.util.logger;
    import re.util.rng;

    // tweens
    import re.util.tweens.ease;
    import re.util.tweens.tween;
}
