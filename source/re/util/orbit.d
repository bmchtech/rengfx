/** component for orbit motion around a point */

module re.util.orbit;

import re.ecs;
import re.math;
import re.time;

/// orbits an entity around a point
class Orbit : Component, Updatable {
    public float angle;
    public float speed;
    public float radius;
    public Vector3 center;

    this(Vector3 center, float radius, float speed, float initial_angle = 0) {
        this.angle = initial_angle;
        this.radius = radius;
        this.speed = speed;
        this.center = center;
    }

    void update() {
        import std.math : sin, cos;

        angle -= speed * Time.delta_time;
        entity.position = center + Vector3(cos(angle) * radius, 0, sin(angle) * radius);
    }
}
