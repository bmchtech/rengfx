module re.phys.rigid3d;

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
    import re.util.dlib;
    import std.math;
    import std.string : format;
    import std.typecons;

    import geom = dmech.geometry;
    import rb = dmech.rigidbody;
    import dm_ray = dmech.raycast;
    import mech = dmech.world;
    import shape = dmech.shape;
    import dl_vec = dlib.math.vector;
    import dl_quat = dlib.math.quaternion;
    import dl_mat = dlib.math.matrix;
    import dlib.container.array;

    /// represents a manager for physics bodies
    class PhysicsManager : Manager {
        /// the maximum number of collisions to support in this world
        public int max_collisions = 1024;
        /// position correction iterations used by physics engine
        public int pos_correction_iterations = 20;
        /// velocity correction iterations used by physics engine
        public int vel_correction_iterations = 40;
        /// gravity in the physics world
        public Vector3 gravity = Vector3(0.0f, -9.80665f, 0.0f); // earth's gravity

        /// the internal dmech physics world
        private mech.PhysicsWorld world;

        /// physics target timestep
        private float _timestep;
        /// used to track time to keep physics timestep fixed
        private float _phys_time = 0;

        private PhysicsBody[rb.RigidBody] _bodies;

        /// the number of dynamic bodies in this physics world
        @property public size_t dynamic_body_count() {
            return world.dynamicBodies.length;
        }

        /// the number of static bodies in this physics world
        @property public size_t static_body_count() {
            return world.staticBodies.length;
        }

        /// the total number of bodies in this physics world
        @property public size_t body_count() {
            return dynamic_body_count + static_body_count;
        }

        override void setup() {
            /// allocate resources to run physics
            import dlib.core.memory : New;

            world = New!(mech.PhysicsWorld)(null, max_collisions);
            world.broadphase = true;
            world.positionCorrectionIterations = pos_correction_iterations;
            world.constraintIterations = vel_correction_iterations;
            world.gravity = convert_vec3(gravity);
            _timestep = 1f / Core.target_fps; // set target _timestep
        }

        override void destroy() {
            import dlib.core.memory : Delete;

            Delete(world);
        }

        override void update() {
            // step the simulation
            _phys_time += Time.delta_time;
            // TODO: should this be while?
            if (_phys_time >= _timestep) {
                _phys_time -= _timestep;

                // sync FROM bodies: physical properties (mass, inertia)
                // sync TO bodies: transforms, momentum
                foreach (comp; _bodies.byValue()) {
                    rb.RigidBody bod = comp._phys_body;

                    // sync properties -> physics engine
                    if (abs(bod.mass - comp.mass) > float.epsilon) {
                        bod.mass = comp.mass;
                        bod.invMass = 1f / comp.mass;
                        // TODO: update mass contribtion of shapes?
                        // foreach (shape; body_comp._phys_shapes) {

                        // }
                    }
                    // TODO: sync inertia? right now it's automatically set from mass

                    // sync velocity
                    bod.linearVelocity = convert_vec3(comp.velocity);
                    bod.angularVelocity = convert_vec3(comp.angular_velocity);
                    bod.maxSpeed = comp.max_speed;

                    // apply forces and impulses
                    // these are queued up, then we apply them all to the object
                    foreach (force; comp._forces) {
                        bod.applyForceAtPos(convert_vec3(force.value),
                                convert_vec3(force.pos) + bod.position);
                    }
                    comp._forces.removeBack(cast(uint) comp._forces.length);
                    foreach (impulse; comp._impulses) {
                        bod.applyImpulse(convert_vec3(impulse.value),
                                convert_vec3(impulse.pos) + bod.position);
                    }
                    comp._impulses.removeBack(cast(uint) comp._impulses.length);
                    foreach (torque; comp._torques) {
                        bod.applyTorque(convert_vec3(torque));
                    }
                    comp._torques.removeBack(cast(uint) comp._torques.length);
                }

                // sync options to world
                world.gravity = convert_vec3(gravity);

                world.update(_timestep);

                foreach (comp; _bodies.byValue()) {
                    rb.RigidBody bod = comp._phys_body;

                    // sync physics engine -> components

                    // sync position
                    auto bod_pos = bod.position;
                    comp.transform.position = convert_vec3(bod_pos);

                    // sync rotation/orientation
                    auto bod_rot = bod.orientation;
                    comp.transform.orientation = convert_quat(bod_rot);

                    // sync velocity
                    comp.velocity = convert_vec3(bod.linearVelocity);
                    comp.angular_velocity = convert_vec3(bod.angularVelocity);
                }
            }
        }

        /// register all colliders in this body
        private void register_colliders(PhysicsBody body_comp) {
            // add colliders to the physics world
            import dlib.core.memory : New;

            auto bod = body_comp._phys_body;

            auto box_colliders = body_comp.entity.get_components!BoxCollider();

            foreach (box; box_colliders) {
                auto box_geom = New!(geom.GeomBox)(world, convert_vec3(box.size));
                auto shape = world.addShapeComponent(bod, box_geom,
                        convert_vec3(box.offset), bod.mass);
                body_comp._shapes[shape] = box;
            }
        }

        /// unregister all colliders in this body
        private void unregister_colliders(PhysicsBody body_comp) {
            import std.range : front;
            import std.algorithm : countUntil, remove;

            // we need to remove from the world each collider that we internally have registered to that body
            foreach (shape; body_comp._shapes.byKey()) {
                world.shapeComponents.removeFirst(shape);
            }

            // then clear the internal collider list
            body_comp._shapes.clear();
        }

        /// registers a body
        private void register(PhysicsBody body_comp) {
            rb.RigidBody bod;
            switch (body_comp._body_type) {
            case PhysicsBody.BodyType.Static:
                bod = world.addStaticBody(convert_vec3(body_comp.transform.position));
                break;
            case PhysicsBody.BodyType.Dynamic:
                bod = world.addDynamicBody(convert_vec3(body_comp.transform.position),
                        body_comp.mass);
                break;
            default:
                assert(0);
            }

            bod.orientation = convert_quat(body_comp.transform.orientation);

            // update registration
            body_comp._phys_body = bod;
            _bodies[bod] = body_comp;

            // add colliders
            register_colliders(body_comp);

            // sync properties
            sync_properties(body_comp);

            // mark as synced
            body_comp.physics_synced = true;
        }

        /// unregisters a body
        private void unregister(PhysicsBody body_comp) {
            // remove colliders
            unregister_colliders(body_comp);

            auto bod = body_comp._phys_body;

            // remove body
            switch (body_comp._body_type) {
            case PhysicsBody.BodyType.Static:
                world.staticBodies.removeFirst(bod);
                break;
            case PhysicsBody.BodyType.Dynamic:
                world.dynamicBodies.removeFirst(bod);
                break;
            default:
                assert(0);
            }

            // mark as unsynced
            body_comp.physics_synced = false;

            // clear registration
            _bodies.remove(bod);
            body_comp._phys_body = null;
        }

        /// sync a body's colliders in the physics engine, necessary when shapes change
        private void sync_colliders(PhysicsBody body_comp) {
            unregister_colliders(body_comp);
            register_colliders(body_comp);
        }

        /// synchronize the transform from body to physics engine
        private void sync_transform(PhysicsBody body_comp) {
            // sync position
            body_comp._phys_body.position = convert_vec3(body_comp.transform.position);

            // sync rotation
            body_comp._phys_body.orientation = convert_quat(body_comp.transform.orientation);
        }

        /// sync physical properties from body to physics engine
        private void sync_properties(PhysicsBody body_comp) {
            auto bod = body_comp._phys_body;
            if (body_comp.custom_gravity) {
                bod.useOwnGravity = true;
                bod.gravity = convert_vec3(body_comp.gravity);
            }
            bod.damping = body_comp.damping;
            bod.bounce = body_comp.bounce;
            bod.friction = body_comp.friction;
        }

        /// cast a ray of a given length in a given direction and return the result. null if no hits.
        public Nullable!RaycastResult raycast(Vector3 start, Vector3 direction, float dist) {
            import std.algorithm.searching : countUntil;

            dm_ray.CastResult cr;
            if (world.raycast(convert_vec3(start), convert_vec3(direction), dist, cr, true, true)) {
                // get matching physics body
                auto body_comp = _bodies[cr.rbody];
                // get matching collider
                auto collider = body_comp._shapes[cr.shape];
                auto res = RaycastResult(convert_vec3(cr.point),
                        convert_vec3(cr.normal), body_comp, collider);
                return Nullable!RaycastResult(res);
            }
            // no result
            return Nullable!RaycastResult.init;
        }
    }

    public struct RaycastResult {
        Vector3 point;
        Vector3 normal;
        PhysicsBody pbody;
        Collider collider;
    }

    /// represents a physics body
    abstract class PhysicsBody : Component {
        // - references to things in the physics engine
        private rb.RigidBody _phys_body;
        // private shape.ShapeComponent[] _phys_shapes;
        private Collider[shape.ShapeComponent] _shapes;

        // - physical properties
        /// object mass
        public float mass = 0;
        /// moment of inertia
        // public float inertia = 1;
        /// max speed of object
        public float max_speed = float.max;
        /// current linear velocity of object
        public Vector3 velocity = Vector3(0, 0, 0);
        /// current angular velocity of object
        public Vector3 angular_velocity = Vector3(0, 0, 0);
        /// damping amount
        public float damping = 0.5;
        /// bounce amount
        public float bounce = 0;
        /// coefficient of friction
        public float friction = 0.5;
        /// whether to use a custom gravity value
        public bool custom_gravity = false;
        /// if custom gravity is enabled, the gravity to use
        public Vector3 gravity = Vector3(0, 0, 0);

        /// whether this body is currently in sync with the physics system
        public bool physics_synced = false;

        private PhysicsManager _mgr;
        private BodyType _body_type;

        /// physics body mode: dynamic or static
        public enum BodyType {
            Dynamic,
            Static
        }

        // - used to queue forces and impulses to be applied by the physics engine
        private DynamicArray!VecAtPoint _forces;
        private DynamicArray!Vector3 _torques;
        private DynamicArray!VecAtPoint _impulses;

        private struct VecAtPoint {
            Vector3 value;
            Vector3 pos;
        }

        /// creates a physics body with a given mass and type
        this(float mass, BodyType type) {
            this.mass = mass;
            _body_type = type;
        }

        override void setup() {
            // register the body in the physics manager
            auto mgr = entity.scene.get_manager!PhysicsManager();
            assert(!mgr.isNull, "scene did not have PhysicsManager registered."
                    ~ "please add that to the scene before creating this component.");
            _mgr = mgr.get;
            _mgr.register(this);
        }

        /// apply an impulse to the physics body
        public void apply_impulse(Vector3 value, Vector3 pos) {
            _impulses.append(VecAtPoint(value, pos));
        }

        /// apply a force to the physics body
        public void apply_force(Vector3 value, Vector3 pos) {
            _forces.append(VecAtPoint(value, pos));
        }

        /// apply a torque to the physics body
        public void apply_torque(Vector3 value) {
            _torques.append(value);
        }

        /// notify physics engine about new physical properties, such as gravity
        public void sync_properties() {
            _mgr.sync_properties(this);
        }

        /// used to notify the physics engine to update colliders if they have changed
        public void sync_colliders() {
            _mgr.sync_colliders(this);
        }

        /// used to notify the physics engine when transform is directly modified
        public void sync_transform() {
            _mgr.sync_transform(this);
        }

        override void destroy() {
            _mgr.unregister(this);
        }
    }

    /// a dynamic physics body that is affected by forces
    public class DynamicBody : PhysicsBody {
        this(float mass = 1f) {
            super(mass, PhysicsBody.BodyType.Dynamic);
        }
    }

    /// a static physics body that is not affected by forces
    public class StaticBody : PhysicsBody {
        this(float mass = 1f) {
            super(mass, PhysicsBody.BodyType.Static);
        }
    }

    @("phys-rigid3d-basic") unittest {
        import re.ng.scene : Scene2D;
        import re.util.test : test_scene;

        class TestScene : Scene2D {
            override void on_start() {
                add_manager(new PhysicsManager());

                auto nt = create_entity("block");
                nt.add_component(new DynamicBody());
            }
        }

        auto test = test_scene(new TestScene());
        test.game.run();

        // check conditions

        test.game.destroy();
    }

    @("phys-rigid3d-lifecycle") unittest {
        import re.ng.scene : Scene2D;
        import re.util.test : test_scene;
        import re.ecs.entity : Entity;

        class TestScene : Scene2D {
            private Entity nt1;

            override void on_start() {
                add_manager(new PhysicsManager());

                nt1 = create_entity("one");
                nt1.add_component(new DynamicBody());
                auto nt2 = create_entity("two");
                nt2.add_component(new DynamicBody());
                auto nt3 = create_entity("three");
                nt3.add_component(new DynamicBody());
            }

            public void kill_one() {
                nt1.destroy();
            }
        }

        auto test = test_scene(new TestScene());
        test.game.run();

        // check conditions
        auto mgr = test.scene.get_manager!PhysicsManager;
        assert(!mgr.isNull);
        assert(mgr.get.body_count == 3, "physics body count does not match");

        (cast(TestScene) test.scene).kill_one();
        assert(mgr.get.body_count == 2, "physics body was not unregistered on component destroy");

        test.game.destroy();
    }

    @("phys-rigid3d-colliders") unittest {
        import re.ng.scene : Scene2D;
        import re.util.test : test_scene;
        import re.ecs.entity : Entity;
        import std.algorithm : canFind;

        class TestScene : Scene2D {
            private Entity nt1;

            override void on_start() {
                add_manager(new PhysicsManager());

                nt1 = create_entity("block");
                nt1.add_component(new BoxCollider(Vector3(1, 1, 1), Vector3Zero));
                nt1.add_component(new DynamicBody());
            }

            /// inform the physics body that the colliders need to be synced
            public void reload_colliders() {
                nt1.get_component!DynamicBody().sync_colliders();
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
        auto mgr = test.scene.get_manager!PhysicsManager.get;
        auto bod = test.scene.get_entity("block").get_component!DynamicBody();

        // check that colliders are registered
        assert(mgr.world.dynamicBodies.data.canFind(bod._phys_body));
        auto shape1 = bod._shapes.keys[0];
        immutable auto collider1_size_x = (cast(geom.GeomBox)(shape1.geometry)).halfSize.x;
        assert(collider1_size_x == 1,
                "collider #1 size from physics engine does not match provided collider size");

        // sync the colliders, then ensure that the registration is different
        scn.reload_colliders();
        auto shape2 = bod._shapes.keys[0];
        assert(shape1 != shape2,
                "colliders were synced, which was supposed to reset collider registration, but entry was not changed");

        // replace the colliders
        scn.replace_colliders();
        assert(bod._shapes.length > 0, "registration entry for new collider missing");
        auto shape3 = bod._shapes.keys[0];
        immutable auto collider3_size_x = (cast(geom.GeomBox)(shape3.geometry)).halfSize.x;
        assert(collider3_size_x == 2,
                "collider #3 size from physics engine does not match replaced collider size");

        test.game.destroy();
    }
}
