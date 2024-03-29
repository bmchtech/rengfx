/** 2d kinematic body */

module re.phys.kin2d;

import re.ecs.component;
import re.ecs.updatable;
import re.math;
import std.math;
import re.time;

class KinBody2D : Component, Updatable {
    mixin Reflect;
    public float mass = 1.0f;
    public Vector2 velocity = Vector2Zero;
    public Vector2 max_velocity = Vector2Zero;
    public Vector2 accel = Vector2Zero;
    public Vector2 drag = Vector2Zero;
    public float max_angular = 0;
    public float angular_velocity = 0;
    public float angular_accel = 0;
    public float angular_drag = 0;

    // - transform

    @property public Vector2 pos() {
        return transform.position2;
    }

    @property public Vector2 pos(Vector2 value) {
        return transform.position2 = value;
    }

    @property public float angle() {
        return transform.rotation_z;
    }

    @property public float angle(float value) {
        return transform.rotation_z = value;
    }

    @property public float stdAngle() {
        return -angle + std.math.PI / 2;
    }

    @property public float stdAngle(float value) {
        return angle = -(value - std.math.PI / 2);
    }

    // misc. getters
    @property public Vector2 momentum() {
        return mass * velocity;
    }

    override void setup() {
    }

    void update() {
        auto dt = Time.delta_time;

        // apply max velocity
        auto vls = velocity.LengthSquared();
        auto mvls = max_velocity.LengthSquared();
        if (mvls > double.epsilon && vls > mvls) {
            // convert to unit and rescale
            auto unit_vel = velocity.Normalize();
            auto ratio = mvls / vls;
            auto reduction_fac = pow(ratio, (1 / 12f));
            // smoothly reduce to max velocity
            velocity = velocity * reduction_fac;
        }

        // new velocity components
        auto nvel_x = velocity.x;
        auto nvel_y = velocity.y;

        // apply acceleration
        nvel_x += accel.x * dt;
        nvel_y += accel.y * dt;

        if (nvel_x > drag.x * dt) {
            nvel_x = nvel_x - drag.x * dt;
        }

        if (nvel_x < -drag.x * dt) {
            nvel_x = nvel_x + drag.x * dt;
        }

        if (abs(nvel_x) < drag.x * dt) {
            nvel_x = 0;
        }

        if (nvel_y > drag.y * dt) {
            nvel_y = nvel_y - drag.y * dt;
        }

        if (nvel_y < -drag.y * dt) {
            nvel_y = nvel_y + drag.y * dt;
        }

        if (abs(nvel_y) < drag.y * dt) {
            nvel_y = 0;
        }

        velocity = Vector2(nvel_x, nvel_y);

        apply_motion(velocity * dt);

        // apply max angular
        if (max_angular > 0) {
            if (angular_velocity > max_angular) {
                angular_velocity = max_angular;
            }

            if (angular_velocity < -max_angular) {
                angular_velocity = -max_angular;
            }
        }

        // apply angular accel
        angular_velocity += angular_accel * dt;

        // apply angular drag
        if (angular_velocity > angular_drag * dt) {
            angular_velocity -= angular_drag * dt;
        }

        if (angular_velocity < -angular_drag * dt) {
            angular_velocity += angular_drag * dt;
        }

        transform.rotation_z = transform.rotation_z + (angular_velocity * dt);
    }

    protected void apply_motion(Vector2 pos_delta) {
        // apply motion to this object. typically this is passed onto a physics body.
        transform.position2 = transform.position2 + pos_delta;
    }
}

@("phys-kin2d")
unittest {
    import re.ng.scene : Scene2D;
    import re.util.test : test_scene;

    class TestScene : Scene2D {
        override void on_start() {
            auto nt = create_entity("block", Vector2(0, 0));
            // add kin body
            auto bod = new KinBody2D();
            bod.accel = Vector2(0, 9.8);
            bod.angular_accel = C_PI_2;
            nt.add_component(bod);
        }
    }

    auto test = test_scene(new TestScene());
    test.game.run();

    // check conditions
    assert(test.scene.get_entity("block").get_component!KinBody2D().pos.y > 0,
            "KinBody2D did not move");
    assert(test.scene.get_entity("block").get_component!KinBody2D()
            .angular_velocity > 0, "KinBody2D did not rotate");

    test.game.destroy();
}
