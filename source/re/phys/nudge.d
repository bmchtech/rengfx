module re.phys.nudge;

import re.ecs.component;
import re.ecs.updatable;
import re.math;
import re.time;
import re.core;
import re.ng.manager;
import re.ng.scene;
import std.math;
import std.string : format;
static import nudge;
import nudge_ext;

/// represents a manager for bodies in a NudgeRealm
class NudgeManager : Manager {
    private NudgeRealm realm;
    private uint item_limit = 1024;

    /// checks whether this scene has a nudge manager installed
    public static bool is_installed(Scene scene) {
        auto existing = scene.get_manager!NudgeManager();
        return !existing.isNull;
    }

    /// get the nudge manager in a scene
    public static NudgeManager get_current(Scene scene) {
        return scene.get_manager!NudgeManager().get;
    }

    /// enable a nudge manager in a scene
    public static void install(Scene scene) {
        scene.managers ~= new NudgeManager();
    }

    /// allocate resources to run physics
    public void allocate() {
        realm = new NudgeRealm(item_limit, item_limit, item_limit);
        realm.allocate();
    }

    override void destroy() {
        realm.destroy();
        realm = null;
    }

    private void simulate() {
        // TODO: update the stuff in the nudge realm
        // TODO: consider refactoring into nudge_ext when finished
    }

    override void update() {
        simulate();
    }

    public void register(NudgeBody body) {
        // TODO: register this body
    }

    public void unregister(NudgeBody body) {
        // TODO: unregister this body
    }
}

class NudgeBody : Component, Updatable {
    public uint nudge_body_id;
    private NudgeManager mgr;

    override void setup() {
        // ensure the nudge system is installed
        if (!NudgeManager.is_installed(entity.scene)) {
            NudgeManager.install(entity.scene);
        }

        mgr = NudgeManager.get_current(entity.scene);

        // register with nudge
        mgr.register(this);
    }

    void update() {
        // copy data from nudge system
        // we use our body ID to access the nudge system
    }

    override void destroy() {
        mgr.unregister(this);
    }
}

@("physics-nudge")
unittest {
    auto mgr = new NudgeManager();

    mgr.allocate();

    // TODO: test some stuff in a headless scene

    mgr.destroy();
}
