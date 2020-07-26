module re.ng.camera.cam3d;

import re.ecs;
import re.time;
import re.math;
import re.gfx.raytypes;
import re.ng.camera.base;
import std.math;
static import raylib;

/// represents a camera for a 3D scene
class SceneCamera3D : SceneCamera {
    private raylib.Camera3D _camera;
    private ProjectionType _projection;

    /// the projection used for the camera
    public enum ProjectionType {
        Perspective,
        Orthographic
    }

    this() {
        _camera = raylib.Camera3D();
        // default settings
        up = Vector3(0, 1, 0); // unit vector y+
        fov = C_PI_4; // 45 deg
        projection = ProjectionType.Perspective;
    }

    /// gets the underlying camera object (used internally)
    @property ref raylib.Camera3D camera() return  {
        return _camera;
    }

    /// gets the projection type
    @property ProjectionType projection() {
        return _projection;
    }

    /// sets the projection type
    @property ProjectionType projection(ProjectionType value) {
        _projection = value;
        switch (_projection) {
        case ProjectionType.Perspective:
            _camera.type = raylib.CameraType.CAMERA_PERSPECTIVE;
            break;
        case ProjectionType.Orthographic:
            _camera.type = raylib.CameraType.CAMERA_ORTHOGRAPHIC;
            break;
        default:
            assert(0);
        }
        return value;
    }

    /// gets the Y-field-of-view in radians
    @property float fov() {
        return _camera.fovy * C_DEG2RAD;
    }

    /// sets the Y-field-of-view in radians
    @property float fov(float value) {
        return _camera.fovy = value * C_RAD2DEG;
    }

    /// gets the direction that is up relative to this camera
    @property Vector3 up() {
        return _camera.up;
    }

    /// sets the direction that is up relative to this camera
    @property Vector3 up(Vector3 value) {
        return _camera.up = value;
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

    /// orient the camera in the direction of a point
    public void look_at(Vector3 target) {
        _camera.target = target;
    }
}

/// controls a camera by making it orbit an entity
class CameraOrbit : Component, Updatable {
    private SceneCamera3D cam;
    /// the target entity to orbit
    public Entity target;
    /// the orbit speed, in radians per second
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
                atan2(to_target.y,
                    sqrt(to_target.x * to_target.x + to_target.z * to_target.z))); // // Camera angle in plane XY (0 aligned with X, move positive CW)
    }

    /// based on https://github.com/raysan5/raylib/blob/6fa6757a8bf90d4b2fd0ce82dace7c7223635efa/src/camera.h#L400
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
