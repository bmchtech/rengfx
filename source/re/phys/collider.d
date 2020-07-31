module re.phys.collider;

import re.ecs.component;
import re.math;

/// a data class that represents a collider
abstract class Collider : Component {
    mixin Reflect;
    public const(Vector3) offset;
    this(Vector3 offset) {
        this.offset = offset;
    }
}

/// a rectangular prism collider
class BoxCollider : Collider {
    mixin Reflect;
    /// the half-size x,y,z dimensions of the collision box
    public const(Vector3) size;

    this(Vector3 size, Vector3 offset) {
        super(offset);
        this.size = size;
    }
}

/// a sphere collider
class SphereCollider : Collider {
    mixin Reflect;
    /// the radius of the collision box
    public const(float) radius;

    this(float radius, Vector3 offset) {
        super(offset);
        this.radius = radius;
    }
}
