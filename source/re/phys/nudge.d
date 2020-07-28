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

        /// holds the list of indices that point to colliders owned by a certain body
        class ColliderRefs {
            /// the list of collider indices
            uint[] indices;
        }

        // map from body component to colliders
        private DualMap!(NudgeBody, ColliderRefs) _box_collider_map;
        // private DualMap!(NudgeBody, ColliderRefs) _sphr_collider_map;

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
            _box_collider_map = new DualMap!(NudgeBody, ColliderRefs);
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

            static const uint steps = 2;
            static const uint iterations = 20;

            float time_step = Time.delta_time / (cast(float) steps);

            for (uint n = 0; n < steps; ++n) {
                // Setup a temporary memory arena. The same temporary memory is reused each iteration.
                nudge.Arena temporary = realm.arena;

                // Find contacts.
                nudge.BodyConnections connections = {}; // NOTE: Custom constraints should be added as body connections.
                nudge.collide(&realm.active_bodies, &realm.contact_data,
                        realm.bodies, realm.colliders, connections, temporary);

                // NOTE: Custom contacts can be added here, e.g., against the static environment.

                // Apply gravity and damping.
                float damping = 1.0f - time_step * 0.25f;

                for (uint i = 0; i < realm.active_bodies.count; ++i) {
                    uint index = realm.active_bodies.indices[i];

                    realm.bodies.momentum[index].velocity[1] -= 9.82f * time_step;

                    realm.bodies.momentum[index].velocity[0] *= damping;
                    realm.bodies.momentum[index].velocity[1] *= damping;
                    realm.bodies.momentum[index].velocity[2] *= damping;

                    realm.bodies.momentum[index].angular_velocity[0] *= damping;
                    realm.bodies.momentum[index].angular_velocity[1] *= damping;
                    realm.bodies.momentum[index].angular_velocity[2] *= damping;
                }

                // Read previous impulses from contact cache.
                nudge.ContactImpulseData* contact_impulses = nudge.read_cached_impulses(realm.contact_cache,
                        realm.contact_data, &temporary);

                // Setup contact constraints and apply the initial impulses.
                nudge.ContactConstraintData* contact_constraints = nudge.setup_contact_constraints(realm.active_bodies,
                        realm.contact_data, realm.bodies, contact_impulses, &temporary);

                // Apply contact impulses. Increasing the number of iterations will improve stability.
                for (uint i = 0; i < iterations; ++i) {
                    nudge.apply_impulses(contact_constraints, realm.bodies);
                    // NOTE: Custom constraint impulses should be applied here.
                }

                // Update contact impulses.
                nudge.update_cached_impulses(contact_constraints, contact_impulses);

                // Write the updated contact impulses to the cache.
                nudge.write_cached_impulses(&realm.contact_cache,
                        realm.contact_data, contact_impulses);

                // Move active bodies.
                nudge.advance(realm.active_bodies, realm.bodies, time_step);
            }
        }

        override void update() {
            simulate();

            // copy data to bodies
            for (int i = 0; i < realm.bodies.count; i++) {
                auto body_comp = _body_map.get(i);

                // copy linear velocity
                auto momentum = &realm.bodies.momentum[i];
                auto vel = Vector3(momentum.velocity[0], momentum.velocity[1], momentum.velocity[2]);
                auto trf = &realm.bodies.transforms[i];
                auto npos_x = trf.position[0];
                auto npos_y = trf.position[1];
                auto npos_z = trf.position[2];
                body_comp.entity.position = Vector3(npos_x, npos_y, npos_z);

                // TODO: support angular velocity
            }
        }

        /// register all colliders in this body
        private void register_colliders(NudgeBody body_comp) {
            // we need to use the body's collider list to populate our internal collider registration list
            // then add the colliders to the realm

            auto body_id = body_comp.nudge_body_id;

            // ensure that nothing is already registered
            assert(!_box_collider_map.has(body_comp),
                    "a collider registration list already exists for this body. call unregister first.");

            // get the collider list
            auto box_colliders = body_comp.entity.get_components!BoxCollider();
            // auto sphere_colliders = body_comp.entity.get_components!SphereCollider();

            _box_collider_map.set(body_comp, new ColliderRefs());

            // add to the realm, and populate our internal registration list
            foreach (box; box_colliders) {
                // add collider to realm
                auto box_index = realm.append_box_collider(body_id,
                        nudge.BoxCollider([box.size.x, box.size.y, box.size.z],
                            0), nudge.Transform([
                                box.offset.x, box.offset.y, box.offset.z
                            ], 0, [0, 0, 0, 0]));

                // update tag
                realm.colliders.boxes.tags[box_index] = box_index;

                // add to registration list
                _box_collider_map.get(body_comp).indices ~= box_index;
            }
        }

        /// unregister all colliders in this body
        private void unregister_colliders(NudgeBody body_comp) {
            import std.range : front;
            import std.algorithm : countUntil, remove;

            // for this, we need to use our internal map of a body's colliders, since its own list may have changed
            // we need to remove from the realm each collider that we internally have registered to that body
            // then clear our internal collider list
            // we don't touch the body's collider list

            auto body_id = body_comp.nudge_body_id;

            // get the registration maps
            auto box_regs = _box_collider_map.get(body_comp);

            // go through and remove each one from the realm
            while (box_regs.indices.length > 0) {
                auto box_ix = box_regs.indices.front;
                // zero the box
                realm.clear_box_collider(box_ix);
                auto tail_index = realm.colliders.boxes.count - 1;
                if (realm.colliders.boxes.count > 1 && box_ix < tail_index) {
                    realm.swap_box_colliders(box_ix, tail_index);

                    // update anything pointing to that (used to be in tail, now is in box_ix)
                    // a. find out what body owns that collider
                    auto owner_body = realm.colliders.boxes.transforms[box_ix].body;
                    // b. get the component
                    auto owner_comp = _body_map.get(owner_body);
                    // c. get the collider list registration for that component
                    auto owner_regs = _box_collider_map.get(owner_comp);
                    // d. replace the box index
                    auto index_of_ref = owner_regs.indices.countUntil(tail_index);
                    owner_regs.indices[index_of_ref] = box_ix;
                }
                // pop the tail box
                realm.pop_last_box_collider();

                // remove the index from the box regs
                box_regs.indices = box_regs.indices.remove!(x => x == box_ix);
            }

            // clear box registrations
            _box_collider_map.remove(body_comp, box_regs);
        }

        /// registers a body
        public void register(NudgeBody body_comp) {
            auto inertia_inverse = 1 / body_comp.inertia;
            nudge.BodyProperties properties = nudge.BodyProperties([
                    inertia_inverse, inertia_inverse, inertia_inverse
                    ], 1 / body_comp.mass);

            if (body_comp.is_static) {
                properties.mass_inverse = 0;
                properties.inertia_inverse = 0;
            }

            // request a body from nudge
            // TODO: eventually add support for rotation
            immutable auto body_id = realm.append_body(nudge.Transform([
                        body_comp.entity.position.x, body_comp.entity.position.y,
                        body_comp.entity.position.z
                    ], 0, [0, 0, 0, 0]), properties, NudgeRealm.zero_momentum);

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

            if (body_comp.is_static) {
                realm.bodies.properties[body_id].mass_inverse = 0;
                realm.bodies.properties[body_id].inertia_inverse = 0;
            } else {
                // update mass
                realm.bodies.properties[body_id].mass_inverse = (1 / body_comp.mass);

                // update inertia
                auto inertia_inverse = 1 / body_comp.inertia;
                realm.bodies.properties[body_id].inertia_inverse = [
                    inertia_inverse, inertia_inverse, inertia_inverse
                ];
            }

            // update colliders
            // this means, remove all existing colliders we own, and (re)add colliders
            unregister_colliders(body_comp);
            register_colliders(body_comp);
        }
    }

    /// represents a physics body that uses the nudge physics system
    class NudgeBody : Component {
        /// reference to the body id inside the nudge realm (used internally by the nudge manager)
        private uint nudge_body_id;

        /// whether this body is currently in sync with the physics system
        public bool physics_synced = false;

        private NudgeManager mgr;

        private float _mass = 1;
        private float _inertia = 1;
        private bool _static_body = false;

        override void setup() {
            // ensure the nudge system is installed
            if (!NudgeManager.is_installed(entity.scene)) {
                NudgeManager.install(entity.scene);
            }

            mgr = NudgeManager.get_current(entity.scene);

            // register with nudge
            mgr.register(this);
        }

        /// gets whether the body is static
        @property public bool is_static() {
            return _static_body;
        }

        /// sets whether the body is static
        @property public bool is_static(bool value) {
            _static_body = value;
            mgr.refresh(this);
            return value;
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

    @("phys-nudge-colliders") unittest {
        import re.ng.scene : Scene2D;
        import re.util.test : test_scene;
        import re.ecs.entity : Entity;

        class TestScene : Scene2D {
            private Entity nt1;

            override void on_start() {
                nt1 = create_entity("block");
                nt1.add_component(new BoxCollider(Vector3(1, 1, 1), Vector3Zero));
                nt1.add_component(new NudgeBody());
            }

            /// inform the physics body that the colliders need to be synced
            public void reload_colliders() {
                nt1.get_component!NudgeBody().sync_colliders();
            }

            /// remove the existing box collider, and replace with a new one, then reload
            public void replace_colliders() {
                nt1.remove_component!BoxCollider();
                nt1.add_component(new BoxCollider(Vector3(2, 2, 2), Vector3Zero));
                reload_colliders();
            }
        }

        auto test = test_scene(new TestScene());
        test.game.run();

        // check conditions
        auto scn = cast(TestScene) test.scene;
        auto mgr = test.scene.get_manager!NudgeManager.get;
        auto bod = test.scene.get_entity("block").get_component!NudgeBody();

        // check that colliders are registered
        assert(mgr._box_collider_map.has(bod), "missing box collider registration entry for body");
        auto bod_reg1 = mgr._box_collider_map.get(bod);
        assert(bod_reg1.indices.length > 0, "registration entry exists, but no index for collider");
        auto collider1_ix = bod_reg1.indices[0];
        immutable auto collider1_size_x = mgr.realm.colliders.boxes.data[collider1_ix].size[0];
        assert(collider1_size_x == 1,
                "collider #1 size from physics engine does not match provided collider size");

        // sync the colliders, then ensure that the registration is different
        scn.reload_colliders();
        auto bod_reg2 = mgr._box_collider_map.get(bod);
        assert(bod_reg1 != bod_reg2,
                "colliders were synced, which was supposed to reset collider registration, but entry was not changed");

        // replace the colliders
        scn.replace_colliders();
        auto bod_reg3 = mgr._box_collider_map.get(bod);
        assert(bod_reg3.indices.length > 0, "registration entry for new collider missing");
        auto collider3_ix = bod_reg3.indices[0];
        immutable auto collider3_size_x = mgr.realm.colliders.boxes.data[collider3_ix].size[0];
        assert(collider3_size_x == 2,
                "collider #3 size from physics engine does not match replaced collider size");

        test.game.destroy();
    }
}
