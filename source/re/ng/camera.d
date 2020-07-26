module re.ng.camera;

import re.ecs;
import re.time;
import re.math;
import re.gfx.raytypes;
import std.math;
static import raylib;

abstract class SceneCamera : Component {
    void update() {

    }
}

class SceneCamera2D : SceneCamera {
    public raylib.Camera2D _camera;
    this() {
        _camera = raylib.Camera2D();
    }

    @property ref raylib.Camera2D camera() return  {
        return _camera;
    }

    override void update() {
        super.update();

        // copy entity to camera transform
        _camera.target = entity.transform.position2;
        _camera.rotation = entity.transform.rotation;
        _camera.zoom = entity.transform.scale.x;
    }
}

class SceneCamera3D : SceneCamera {
    private raylib.Camera3D _camera;

    this() {
        _camera = raylib.Camera3D();
    }

    @property ref raylib.Camera3D camera() return  {
        return _camera;
    }

    override void update() {
        super.update();

        // copy entity to camera transform
        _camera.position = entity.transform.position;

        // import std.stdio : writefln;
        // writefln("cam pos: %s", _camera.position);

        // update raylib camera
        raylib.UpdateCamera(&_camera);
    }
}

class CameraOrbit : Component, Updatable {
    private SceneCamera3D cam;
    public Entity target;
    public float speed;
    private Vector2 _angle; // xz plane camera angle
    private float _target_dist;
    private enum third_person_dist = 1.2f;

    this(Entity target, float speed) {
        this.target = target;
        this.speed = speed;
    }

    override void setup() {
        cam = entity.get_component!SceneCamera3D();
        auto to_target = target.position - entity.position;

        _target_dist = raymath.Vector3Length(to_target);
        _angle = Vector2(atan2(to_target.x, to_target.z), // Camera angle in plane XZ (0 aligned with Z, move positive CCW)
                atan2(to_target.y, sqrt(to_target.x * to_target.x + to_target.z * to_target.z))); // // Camera angle in plane XY (0 aligned with X, move positive CW)
    }

    // based on https://github.com/raysan5/raylib/blob/6fa6757a8bf90d4b2fd0ce82dace7c7223635efa/src/camera.h#L400
    void update() {
        _angle.x += speed * Time.delta_time; // camera orbit angle

        // camera distance clamp
        if (_target_dist < third_person_dist)
            _target_dist = third_person_dist;

        // update camera position with changes
        auto npos_x = sin(_angle.x) * _target_dist * cos(_angle.y) + target.position.x;
        auto npos_y = ((_angle.y <= 0.0f) ? 1 : -1) * sin(
                _angle.y) * _target_dist * sin(_angle.y) + target.position.y;
        auto npos_z = cos(_angle.x) * _target_dist * cos(_angle.y) + target.position.z;
        entity.position = Vector3(npos_x, npos_y, npos_z);
    }
}
