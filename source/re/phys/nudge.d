module re.phys.nudge;

import re.ecs.component;
import re.ecs.updatable;
import re.math;
import re.time;
import re.core;
import re.ng.manager;
import std.math;
import std.string : format;
static import nudge;

class NudgeManager : Manager {
    /// whether this manager is currently enabled
    public static bool installed = false;

    private enum uint body_limit = 2048;
    private enum uint max_body_count = body_limit;
    private enum uint max_box_count = body_limit;
    private enum uint max_sphere_count = body_limit;

    private enum nudge.Transform identity_transform = nudge.Transform([0, 0, 0],
                0, [0.0f, 0.0f, 0.0f, 1.0f]);

    private static nudge.Arena arena;
    private static nudge.BodyData bodies;
    private static nudge.ColliderData colliders;
    private static nudge.ContactData contact_data;
    private static nudge.ContactCache contact_cache;
    private static nudge.ActiveBodies active_bodies;

    public static uint body_count;

    // map from body id to component
    private static NudgeBody[uint] _component_map;

    /// enable this manager
    public static void install() {
        Core.managers ~= new NudgeManager();

    }

    /// allocate resources to run physics
    public static void allocate() {
        import core.stdc.stdlib : malloc;

        auto bytes_alloced = 0;

        void* alloc_mem(size_t size) {
            bytes_alloced += size;
            return malloc(size);
        }

        // allocate stuff
        // TODO: support dynamic reallocation: start with a small body count and then increase

        // Allocate memory for simulation arena.
        arena.size = 64 * 1024 * 1024;
        arena.data = alloc_mem(arena.size);

        // Allocate memory for bodies, colliders, and contacts.
        active_bodies.capacity = max_box_count;
        active_bodies.indices = cast(ushort*)(alloc_mem(ushort.sizeof * max_body_count));

        bodies.idle_counters = cast(ubyte*)(alloc_mem(ubyte.sizeof * max_body_count));
        bodies.transforms = cast(nudge.Transform*)(
                alloc_mem(nudge.Transform.sizeof * max_body_count));
        bodies.momentum = cast(nudge.BodyMomentum*)(
                alloc_mem(nudge.BodyMomentum.sizeof * max_body_count));
        bodies.properties = cast(nudge.BodyProperties*)(
                alloc_mem(nudge.BodyProperties.sizeof * max_body_count));

        colliders.boxes.data = cast(nudge.BoxCollider*)(
                alloc_mem(nudge.BoxCollider.sizeof * max_box_count));
        colliders.boxes.tags = cast(uint*)(alloc_mem(ushort.sizeof * max_box_count));
        colliders.boxes.transforms = cast(nudge.Transform*)(
                alloc_mem(nudge.Transform.sizeof * max_box_count));

        colliders.spheres.data = cast(nudge.SphereCollider*)(
                alloc_mem(nudge.SphereCollider.sizeof * max_sphere_count));
        colliders.spheres.tags = cast(uint*)(alloc_mem(ushort.sizeof * max_sphere_count));
        colliders.spheres.transforms = cast(nudge.Transform*)(
                alloc_mem(nudge.Transform.sizeof * max_sphere_count));

        contact_data.capacity = max_body_count * 64;
        contact_data.bodies = cast(nudge.BodyPair*)(
                alloc_mem(nudge.BodyPair.sizeof * contact_data.capacity));
        contact_data.data = cast(nudge.Contact*)(
                alloc_mem(nudge.Contact.sizeof * contact_data.capacity));
        contact_data.tags = cast(ulong*)(alloc_mem(ulong.sizeof * contact_data.capacity));
        contact_data.sleeping_pairs = cast(uint*)(alloc_mem(uint.sizeof * contact_data.capacity));

        contact_cache.capacity = max_body_count * 64;
        contact_cache.data = cast(nudge.CachedContactImpulse*)(
                alloc_mem(nudge.CachedContactImpulse.sizeof * contact_cache.capacity));
        contact_cache.tags = cast(ulong*)(alloc_mem(ulong.sizeof * contact_cache.capacity));

        version (unittest) {
        } else {
            Core.log.info(format("allocated %s bytes of memory for NUDGE physics", bytes_alloced));
        }
    }

    private void simulate() {
        enum uint steps = 2;
        enum uint iterations = 20;

        float time_step = 1.0f / (60.0f * cast(float) steps);

        for (uint n = 0; n < steps; ++n) {
            // Setup a temporary memory arena. The same temporary memory is reused each iteration.
            nudge.Arena temporary = arena;

            // Find contacts.
            nudge.BodyConnections connections = {}; // NOTE: Custom constraints should be added as body connections.
            nudge.collide(&active_bodies, &contact_data, bodies, colliders,
                    connections, temporary);

            // NOTE: Custom contacts can be added here, e.g., against the static environment.

            // Apply gravity and damping.
            float damping = 1.0f - time_step * 0.25f;

            for (uint i = 0; i < active_bodies.count; ++i) {
                uint index = active_bodies.indices[i];

                bodies.momentum[index].velocity[1] -= 9.82f * time_step;

                bodies.momentum[index].velocity[0] *= damping;
                bodies.momentum[index].velocity[1] *= damping;
                bodies.momentum[index].velocity[2] *= damping;

                bodies.momentum[index].angular_velocity[0] *= damping;
                bodies.momentum[index].angular_velocity[1] *= damping;
                bodies.momentum[index].angular_velocity[2] *= damping;
            }

            // Read previous impulses from contact cache.
            nudge.ContactImpulseData* contact_impulses = nudge.read_cached_impulses(contact_cache,
                    contact_data, &temporary);

            // Setup contact constraints and apply the initial impulses.
            nudge.ContactConstraintData* contact_constraints = nudge.setup_contact_constraints(active_bodies,
                    contact_data, bodies, contact_impulses, &temporary);

            // Apply contact impulses. Increasing the number of iterations will improve stability.
            for (uint i = 0; i < iterations; ++i) {
                nudge.apply_impulses(contact_constraints, bodies);
                // NOTE: Custom constraint impulses should be applied here.
            }

            // Update contact impulses.
            nudge.update_cached_impulses(contact_constraints, contact_impulses);

            // Write the updated contact impulses to the cache.
            nudge.write_cached_impulses(&contact_cache, contact_data, contact_impulses);

            // Move active bodies.
            nudge.advance(active_bodies, bodies, time_step);
        }
    }

    override void update() {
        // TODO: update nudge
        simulate();
    }

    /// register a body, and return the id
    public static void register_body(NudgeBody new_body) {
        // get a free ID
        auto id = body_count;
        new_body.nudge_body_id = id;

        // store in hash table
        _component_map[id] = new_body;

        body_count++;
    }

    public static void unregister_body(NudgeBody rm_body) {
        auto id = rm_body.nudge_body_id;
        // empty our slot
        // TODO: actually handle this
        // swap to tail
        auto tail_pos = body_count - 1;
        if (body_count > 1 && id != tail_pos) {

        }
    }
}

abstract class NudgeBody : Component, Updatable {
    public uint nudge_body_id;

    override void setup() {
        // ensure the nudge system is installed
        if (!NudgeManager.installed) {
            NudgeManager.allocate();
            NudgeManager.install();
        }

        // register with nudge
        NudgeManager.register_body(this);
    }

    void update() {
        // copy data from nudge system
        // we use our body ID to access the nudge system
    }

    override void destroy() {
        NudgeManager.unregister_body(this);
    }
}

@("physics-nudge")
unittest {
    // set up mem
    NudgeManager.allocate();

    // auto bod1 = 
}
