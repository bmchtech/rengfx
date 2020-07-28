module re.phys.nudge;

version (physics) {
    import re.ecs.component;
    import re.ecs.updatable;
    import re.math;
    import re.time;
    import re.core;
    import re.ng.manager;
    import re.ng.scene;
    import re.phys.collider;
    import re.util.dual_map;
    import std.math;
    import std.string : format;
    static import nudge;
    import nudge_ext;

    /// represents a manager for bodies in a NudgeRealm
    class NudgeManager : Manager {
        private NudgeRealm realm;
        private uint item_limit = 1024;

        /// dual map from NudgeBody to physics body index
        private DualMap!(NudgeBody, uint) _body_map;

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

        @property public size_t body_count() {
            return _body_map.count;
        }

        /// allocate resources to run physics
        public void allocate() {
            realm = new NudgeRealm(item_limit, item_limit, item_limit);
            realm.allocate();
            _body_map = new DualMap!(NudgeBody, uint);
        }

        override void destroy() {
            realm.destroy();
            realm = null;
            _body_map.clear();
            _body_map = null;
        }

        private void simulate() {
            // TODO: update the stuff in the nudge realm
            // TODO: consider refactoring into nudge_ext when finished
        }

        override void update() {
            simulate();
        }

        /// register all colliders in this body
        private void register_colliders(NudgeBody body_comp) {
            // TODO: implement
            // we need to use the body's collider list to populate our internal collider registration list
            // then add the colliders to the realm
        }

        /// unregister all colliders in this body
        private void unregister_colliders(NudgeBody body_comp) {
            // TODO: implement
            // for this, we need to use our internal map of a body's colliders, since its own list may have changed
            // we need to remove from the realm each collider that we internally have registered to that body
            // then clear our internal collider list
            // we don't touch the body's collider list
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
            _body_map.set(body_comp, body_id);

            // add colliders
            register_colliders(body_comp);
        }

        /// unregisters a body
        public void unregister(NudgeBody body_comp) {
            auto body_id = body_comp.nudge_body_id;

            // remove colliders
            unregister_colliders(body_comp);

            // remove from map
            _body_map.remove(body_id);

            // - reorganize the bodies array so it is packed again

            // 1. clear the body we are disposing
            realm.clear_body(body_id);
            // 2. check if it needs to be swapped
            auto cleared_slot = body_id;
            auto tail_index = realm.bodies.count - 1;
            if (realm.bodies.count > 1 && body_id < tail_index) {
                // 3. it needs to be swapped: move our now cleared slot to the end
                // and move the body there back
                // then update our references to them
                realm.swap_bodies(body_id, tail_index);
                // specifically, the body that previously pointed to tail
                // should now point to the leftward slot, which we just cleared

                // a. get the component's body
                auto swap_comp = _body_map.get(tail_index);
                // b. drop the map entry
                _body_map.remove(swap_comp, tail_index);
                // c. set the body index
                swap_comp.nudge_body_id = cleared_slot;
                // d. update the map
                _body_map.set(swap_comp, cleared_slot);

            }
            // 4. our removed body is at the end, we can safely pop
            realm.pop_last_body();

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

            // update colliders
            // this means, remove all existing colliders we own, and (re)add colliders
            unregister_colliders(body_comp);
            register_colliders(body_comp);
        }
    }

    /// represents a physics body that uses the nudge physics system
    class NudgeBody : Component, Updatable {
        /// reference to the body id inside the nudge realm (used internally by the nudge manager)
        private uint nudge_body_id;

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
            // TODO: copy data from nudge system?
            // this could also be handled by the manager
        }

        /// used to notify the physics engine to update colliders if they have changed
        public void sync_colliders() {
            mgr.refresh(this);
        }

        override void destroy() {
            mgr.unregister(this);
        }
    }

    @("phys-nudge-basic") unittest {
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

    @("phys-nudge-lifecycle") unittest {
        import re.ng.scene : Scene2D;
        import re.util.test : test_scene;
        import re.ecs.entity : Entity;

        class TestScene : Scene2D {
            private Entity nt1;

            override void on_start() {
                nt1 = create_entity("one");
                nt1.add_component(new NudgeBody());
                auto nt2 = create_entity("two");
                nt2.add_component(new NudgeBody());
                auto nt3 = create_entity("three");
                nt3.add_component(new NudgeBody());
            }

            public void kill_one() {
                nt1.destroy();
            }
        }

        auto test = test_scene(new TestScene());
        test.game.run();

        // check conditions
        auto mgr = test.scene.get_manager!NudgeManager;
        assert(!mgr.isNull);
        assert(mgr.get.body_count == 3, "physics body count does not match");

        (cast(TestScene) test.scene).kill_one();
        assert(mgr.get.body_count == 2, "physics body was not unregistered on component destroy");

        test.game.destroy();
    }
}
