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
    import std.math;
    import std.string : format;

    import geom = dmech.geometry;
    import rb = dmech.rigidbody;
    import mech = dmech.world;
    import shape = dmech.shape;
    import dl_vec = dlib.math.vector;
    import dl_mat = dlib.math.matrix;

    /// represents a manager for physics bodies
    class PhysicsManager : Manager {
        private enum _max_collisions = 1024;
        private mech.PhysicsWorld world;

        /// checks whether this scene has a nudge manager installed
        public static bool is_installed(Scene scene) {
            auto existing = scene.get_manager!PhysicsManager();
            return !existing.isNull;
        }

        /// get the nudge manager in a scene
        public static PhysicsManager get_current(Scene scene) {
            return scene.get_manager!PhysicsManager().get;
        }

        /// enable a nudge manager in a scene
        public static void install(Scene scene) {
            auto manager = new PhysicsManager();
            manager.allocate();
            scene.managers ~= manager;
        }

        @property public size_t dynamic_body_count() {
            return world.dynamicBodies.length;
        }

        @property public size_t static_body_count() {
            return world.staticBodies.length;
        }

        @property public size_t body_count() {
            return dynamic_body_count + static_body_count;
        }

        /// allocate resources to run physics
        public void allocate() {
            import dlib.core.memory : New;

            world = New!(mech.PhysicsWorld)(null, _max_collisions);
        }

        override void destroy() {
            import dlib.core.memory : Delete;

            Delete(world);
        }

        override void update() {
            // step the simulation
            world.update(Time.delta_time);

            // TODO: copy data to bodies
        }

        pragma(inline, true) {
            private dl_vec.Vector3f convert_vec3(const(Vector3) vec) {
                return dl_vec.Vector3f(vec.x, vec.y, vec.z);
            }

            private Vector3 convert_vec3(const(dl_vec.Vector3f) vec) {
                return Vector3(vec.x, vec.y, vec.z);
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
                body_comp._phys_shapes ~= shape;
            }
        }

        /// unregister all colliders in this body
        private void unregister_colliders(PhysicsBody body_comp) {
            import std.range : front;
            import std.algorithm : countUntil, remove;

            // we need to remove from the world each collider that we internally have registered to that body
            foreach (shape; body_comp._phys_shapes) {
                world.shapeComponents.removeFirst(shape);
            }

            // then clear our internal collider list
            body_comp._phys_shapes = [];
        }

        /// registers a body
        public void register(PhysicsBody body_comp) {
            rb.RigidBody bod;
            switch (body_comp._body_type) {
            case PhysicsBody.BodyType.Static:
                bod = world.addStaticBody(convert_vec3(body_comp.transform.position));
                break;
            case PhysicsBody.BodyType.Dynamic:
                bod = world.addDynamicBody(convert_vec3(body_comp.transform.position));
                break;
            default:
                assert(0);
            }

            // update registration
            body_comp._phys_body = bod;

            // add colliders
            register_colliders(body_comp);

            // mark as synced
            body_comp.physics_synced = true;
        }

        /// unregisters a body
        public void unregister(PhysicsBody body_comp) {
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
            body_comp._phys_body = null;
        }

        /// used to sync a body's properties with the physics system when they change
        public void refresh(PhysicsBody body_comp) {
            // TODO
        }
    }

    /// represents a physics body
    abstract class PhysicsBody : Component {
        /// whether this body is currently in sync with the physics system
        public bool physics_synced = false;

        private rb.RigidBody _phys_body;
        private shape.ShapeComponent[] _phys_shapes;

        private float _mass = 1;
        private float _inertia = 1;

        private PhysicsManager mgr;
        private BodyType _body_type;

        public enum BodyType {
            Dynamic,
            Static
        }

        this(BodyType type) {
            _body_type = type;
        }

        override void setup() {
            // ensure the nudge system is installed
            if (!PhysicsManager.is_installed(entity.scene)) {
                PhysicsManager.install(entity.scene);
            }

            mgr = PhysicsManager.get_current(entity.scene);

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

        /// used to notify the physics engine to update colliders if they have changed
        public void sync_colliders() {
            mgr.refresh(this);
        }

        override void destroy() {
            mgr.unregister(this);
        }
    }

    public class DynamicBody : PhysicsBody {
        this() {
            super(PhysicsBody.BodyType.Dynamic);
        }
    }

    public class StaticBody : PhysicsBody {
        this() {
            super(PhysicsBody.BodyType.Static);
        }
    }

    @("phys-rigid3d-basic") unittest {
        import re.ng.scene : Scene2D;
        import re.util.test : test_scene;

        class TestScene : Scene2D {
            override void on_start() {
                auto nt = create_entity("block");
                // add nudge physics
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
}
