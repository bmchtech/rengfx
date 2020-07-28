module re.phys.nudge;

version (physics) {
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

        /// map from NudgeBody to physics body index
        private uint[NudgeBody] _body_map;
        private NudgeBody[uint] _body_map_reverse;

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
            auto manager = new NudgeManager();
            manager.allocate();
            scene.managers ~= manager;
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

        /// registers a body
        public void register(NudgeBody body_comp) {
            auto inertia_inverse = 1 / body_comp.inertia;
            nudge.BodyProperties properties = nudge.BodyProperties([
                    inertia_inverse, inertia_inverse, inertia_inverse
                    ], 1 / body_comp.mass);

            // request a body from nudge
            immutable auto body_id = realm.append_body(NudgeRealm.identity_transform,
                    properties, NudgeRealm.zero_momentum);

            body_comp.nudge_body_id = body_id;
            body_comp.physics_synced = true;

            // store in map
            _body_map[body_comp] = body_id;
        }

        /// unregisters a body
        public void unregister(NudgeBody body_comp) {
            auto body_id = body_comp.nudge_body_id;

            // swap indices in realm


            // mark body as unsynced
            body_comp.nudge_body_id = 0;
            body_comp.physics_synced = false;
        }

        /// used to sync a body's properties with the physics system when they change
        public void refresh(NudgeBody body_comp) {
            auto body_id = body_comp.nudge_body_id;
            // update mass
            realm.bodies.properties[body_id].mass_inverse = (1 / body_comp.mass);

            // update inertia
            auto inertia_inverse = 1 / body_comp.inertia;
            realm.bodies.properties[body_id].inertia_inverse = [
                inertia_inverse, inertia_inverse, inertia_inverse
            ];
        }
    }

    /// represents a physics body that uses the nudge physics system
    class NudgeBody : Component, Updatable {
        public uint nudge_body_id;

        /// whether this body is currently in sync with the physics system
        public bool physics_synced = false;

        private NudgeManager mgr;

        private float _mass;
        private float _inertia;

        override void setup() {
            // ensure the nudge system is installed
            if (!NudgeManager.is_installed(entity.scene)) {
                NudgeManager.install(entity.scene);
            }

            mgr = NudgeManager.get_current(entity.scene);

            // register with nudge
            mgr.register(this);
        }

        /// gets the body's mass
        @property public float mass() {
            return _mass;
        }

        /// sets the body's mass
        @property public float mass(float value) {
            _mass = value;
            mgr.refresh(this);
            return value;
        }

        /// gets the body's moment of inertia
        @property public float inertia() {
            return _inertia;
        }

        /// sets the body's moment of inertia
        @property public float inertia(float value) {
            _inertia = value;
            mgr.refresh(this);
            return _inertia;
        }

        void update() {
            // copy data from nudge system
            // we use our body ID to access the nudge system
        }

        override void destroy() {
            mgr.unregister(this);
        }
    }

    @("phys-nudge-basic")
    unittest {
        auto mgr = new NudgeManager();

        mgr.allocate();

        // TODO: test some stuff in a headless scene

        mgr.destroy();
    }

    @("phys-nudge-scene")
    unittest {
        import re.ng.scene : Scene2D;
        import re.util.test : test_scene;

        class TestScene : Scene2D {
            override void on_start() {
                auto nt = create_entity("block");
                // add nudge physics
                nt.add_component(new NudgeBody());
            }
        }

        auto test = test_scene(new TestScene());
        test.game.run();

        // check conditions

        test.game.destroy();
    }
}
