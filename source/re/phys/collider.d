module re.phys.collider;

import re.ecs.component;

/// a data class that represents a collider
abstract class Collider : Component {
    public const(Vector3) offset;
    this(Vector3 offset) {
        this.offset = offset;
    }
}

/// a rectangular prism collider
class BoxCollider : Collider {
    /// the x,y,z dimensions of the collision box
    public const(Vector3) size;

    this(Vector3 size, Vector3 offset) {
        super(offset);
        this.size = size;
    }
}

/// a sphere collider
class SphereCollider : Collider {
    /// the radius of the collision box
    public const(float) radius;

    this(float radius, Vector3 offset) {
        super(offset);
        this.radius = radius;
    }
}
