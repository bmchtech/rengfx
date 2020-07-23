module re.phys.kin_body;

import re.ecs.component;
import re.ecs.updatable;
import re.math;
import std.math;
import re.time;

class PhysicsBody2d : Component {
    public float mass = 1.0f;
    public Vector2 velocity = Vector2Zero;
    @property public Vector2 momentum() {
        return mass * velocity;
    }
}

class KinBody2d : PhysicsBody2d, Updatable {
    public Vector2 maxVelocity;
    public Vector2 accel;
    public Vector2 drag;
    public float max_angular;
    public float angular_velocity;
    public float angular_accel;
    public float angular_drag;

    // - transform

    @property public Vector2 pos() {
        return transform.position2;
    }

    @property public Vector2 pos(Vector2 value) {
        return transform.position2 = value;
    }

    @property public float angle() {
        return transform.rotation;
    }

    @property public float angle(float value) {
        return transform.rotation = value;
    }

    @property public float stdAngle() {
        return -angle + std.math.PI / 2;
    }

    @property public float stdAngle(float value) {
        return angle = -(value - std.math.PI / 2);
    }

    override void setup() {
    }

    void update() {
        auto dt = Time.delta_time;

        auto vls = velocity.LengthSquared();
        auto mvls = maxVelocity.LengthSquared();
        if (mvls > double.epsilon && vls > mvls) {
            // convert to unit and rescale
            auto unit_vel = velocity.Normalize();
            auto ratio = mvls / vls;
            auto reduction_fac = pow(ratio, (1 / 12f));
            // smoothly reduce to max velocity
            velocity = velocity * reduction_fac;
        }

        if (velocity.x > drag.x * dt) {
            velocity.x -= drag.x * dt;
        }

        if (velocity.x < -drag.x * dt) {
            velocity.x += drag.x * dt;
        }

        if (abs(velocity.x) < drag.x * dt) {
            velocity.x = 0;
        }

        if (velocity.y > drag.y * dt) {
            velocity.y -= drag.y * dt;
        }

        if (velocity.y < -drag.y * dt) {
            velocity.y += drag.y * dt;
        }

        if (abs(velocity.y) < drag.y * dt) {
            velocity.y = 0;
        }

        apply_motion(velocity * dt);

        angular_velocity += angular_accel * dt;
        if (max_angular > 0) {
            if (angular_velocity > max_angular) {
                angular_velocity = max_angular;
            }

            if (angular_velocity < -max_angular) {
                angular_velocity = -max_angular;
            }
        }

        if (angular_velocity > angular_drag * dt) {
            angular_velocity -= angular_drag * dt;
        }

        if (angular_velocity < -angular_drag * dt) {
            angular_velocity += angular_drag * dt;
        }

        angle = angle + (angular_velocity * dt);
    }

    protected void apply_motion(Vector2 pos_delta) {
        // apply motion to this object. typically this is passed onto a physics body.
        transform.position2 = transform.position2 + pos_delta;
    }
}
