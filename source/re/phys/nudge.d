module re.phys.nudge;

import re.ecs.component;
import re.ecs.updatable;
import re.math;
import re.time;
import re.ng.manager;
import std.math;
static import nudge;

class NudgeManager : Manager {
    /// whether this manager is currently enabled
    public static bool installed = false;

    private static const uint max_body_count = 2048;
    private static const uint max_box_count = 2048;
    private static const uint max_sphere_count = 2048;

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
        import re.core : Core;
        import core.stdc.stdlib : malloc;

        // allocate stuff
        // Allocate memory for simulation arena.
        arena.size = 64 * 1024 * 1024;
        arena.data = malloc(arena.size);

        // Allocate memory for bodies, colliders, and contacts.
        active_bodies.capacity = max_box_count;
        active_bodies.indices = cast(ushort*)(malloc(ushort.sizeof * max_body_count));

        bodies.idle_counters = cast(ubyte*)(malloc(ubyte.sizeof * max_body_count));
        bodies.transforms = cast(nudge.Transform*)(malloc(nudge.Transform.sizeof * max_body_count));
        bodies.momentum = cast(nudge.BodyMomentum*)(
                malloc(nudge.BodyMomentum.sizeof * max_body_count));
        bodies.properties = cast(nudge.BodyProperties*)(
                malloc(nudge.BodyProperties.sizeof * max_body_count));

        colliders.boxes.data = cast(nudge.BoxCollider*)(
                malloc(nudge.BoxCollider.sizeof * max_box_count));
        colliders.boxes.tags = cast(uint*)(malloc(ushort.sizeof * max_box_count));
        colliders.boxes.transforms = cast(nudge.Transform*)(
                malloc(nudge.Transform.sizeof * max_box_count));

        colliders.spheres.data = cast(nudge.SphereCollider*)(
                malloc(nudge.SphereCollider.sizeof * max_sphere_count));
        colliders.spheres.tags = cast(uint*)(malloc(ushort.sizeof * max_sphere_count));
        colliders.spheres.transforms = cast(nudge.Transform*)(
                malloc(nudge.Transform.sizeof * max_sphere_count));

        contact_data.capacity = max_body_count * 64;
        contact_data.bodies = cast(nudge.BodyPair*)(
                malloc(nudge.BodyPair.sizeof * contact_data.capacity));
        contact_data.data = cast(nudge.Contact*)(
                malloc(nudge.Contact.sizeof * contact_data.capacity));
        contact_data.tags = cast(ulong*)(malloc(ulong.sizeof * contact_data.capacity));
        contact_data.sleeping_pairs = cast(uint*)(malloc(uint.sizeof * contact_data.capacity));

        contact_cache.capacity = max_body_count * 64;
        contact_cache.data = cast(nudge.CachedContactImpulse*)(
                malloc(nudge.CachedContactImpulse.sizeof * contact_cache.capacity));
        contact_cache.tags = cast(ulong*)(malloc(ulong.sizeof * contact_cache.capacity));

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
