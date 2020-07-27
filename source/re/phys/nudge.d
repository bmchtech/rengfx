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

    private enum body_limit = 2048;
    private static const uint max_body_count = body_limit;
    private static const uint max_box_count = body_limit;
    private static const uint max_sphere_count = body_limit;

    private static const nudge.Transform identity_transform = nudge.Transform([
            0, 0, 0
            ], 0, [0.0f, 0.0f, 0.0f, 1.0f]);

    private static nudge.Arena arena;
    private static nudge.BodyData bodies;
    private static nudge.ColliderData colliders;
    private static nudge.ContactData contact_data;
    private static nudge.ContactCache contact_cache;
    private static nudge.ActiveBodies active_bodies;

    /// enable this manager
    public static void install() {
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

        Core.log.info(format("allocating %s bytes of memory for NUDGE physics", bytes_alloced));

        Core.managers ~= new NudgeManager();
    }
}

class NudgeBody : Component, Updatable {
    override void setup() {
        // ensure the nudge system is installed
        if (!NudgeManager.installed) {
            NudgeManager.install();
        }
    }

    void update() {

    }
}
