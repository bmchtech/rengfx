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
    mixin Reflect;
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

    /// orient the camera in the direction of an entity
    public void look_at(Entity entity) {
        look_at(entity.position);
    }
}

abstract class CameraFollow3D : Component, Updatable {
    mixin Reflect;
    protected SceneCamera3D cam;
    /// the target entity
    public Entity target;
    protected enum third_person_dist = 1.2f;
    protected Vector2 _angle; // xz plane camera angle
    protected float _target_dist;

    this(Entity target) {
        this.target = target;
    }

    override void setup() {
        cam = entity.get_component!SceneCamera3D();

        auto to_target = target.position - entity.position;

        _target_dist = raymath.Vector3Length(to_target);
        _angle = Vector2(atan2(to_target.x, to_target.z), // Camera angle in plane XZ (0 aligned with Z, move positive CCW)
                atan2(to_target.y,
                    sqrt(to_target.x * to_target.x + to_target.z * to_target.z))); // // Camera angle in plane XY (0 aligned with X, move positive CW)
    }
}

/// controls a camera by making it orbit an entity
class CameraOrbit : CameraFollow3D {
    mixin Reflect;
    /// the orbit speed, in radians per second
    public float speed;

    this(Entity target, float speed) {
        super(target);
        this.speed = speed;
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

class CameraThirdPerson : CameraFollow3D {
    import re.input : Keys, Input, VirtualButton;

    mixin Reflect;
    private Vector2 _angle; // xz plane camera angle
    public float move_sensitivity = 20;
    public float look_sensitivity = 0.003;
    protected enum third_person_min_clamp = 5;
    protected enum third_person_max_clamp = -85;

    this(Entity target) {
        super(target);
    }

    // based on https://github.com/raysan5/raylib/blob/6fa6757a8bf90d4b2fd0ce82dace7c7223635efa/src/camera.h#L458
    void update() {
        // bool direction[6] = {
        //     IsKeyDown(CAMERA.moveControl[MOVE_FRONT]), IsKeyDown(CAMERA.moveControl[MOVE_BACK]),
        //         IsKeyDown(CAMERA.moveControl[MOVE_RIGHT]), IsKeyDown(CAMERA.moveControl[MOVE_LEFT]),
        //         IsKeyDown(CAMERA.moveControl[MOVE_UP]), IsKeyDown(CAMERA.moveControl[MOVE_DOWN])
        // };
        // bool[6] direction = [false, false, false, false, false, false];
        bool[6] direction = [
            Input.is_key_down(Keys.KEY_W), Input.is_key_down(Keys.KEY_S),
            Input.is_key_down(Keys.KEY_D), Input.is_key_down(Keys.KEY_A),
            Input.is_key_down(Keys.KEY_E), Input.is_key_down(Keys.KEY_Q)
        ];
        enum MOVE_FRONT = 0;
        enum MOVE_BACK = 1;
        enum MOVE_RIGHT = 2;
        enum MOVE_LEFT = 3;
        enum MOVE_UP = 4;
        enum MOVE_DOWN = 5;

        auto dpos_x = (sin(_angle.x) * direction[MOVE_BACK] - sin(
                _angle.x) * direction[MOVE_FRONT] - cos(
                _angle.x) * direction[MOVE_LEFT] + cos(_angle.x) * direction[MOVE_RIGHT]) / move_sensitivity;
        auto npos_x = transform.position.x + dpos_x;

        auto dpos_y = (sin(_angle.y) * direction[MOVE_FRONT] - sin(
                _angle.y) * direction[MOVE_BACK] + 1.0f * direction[MOVE_UP]
                - 1.0f * direction[MOVE_DOWN]) / move_sensitivity;
        auto npos_y = transform.position.y + dpos_y;

        auto dpos_z = (cos(_angle.x) * direction[MOVE_BACK] - cos(
                _angle.x) * direction[MOVE_FRONT] + sin(
                _angle.x) * direction[MOVE_LEFT] - sin(_angle.x) * direction[MOVE_RIGHT]) / move_sensitivity;
        auto npos_z = transform.position.z + dpos_z;

        transform.position = Vector3(npos_x, npos_y, npos_z);

        // CAMDATA orientation calculation
        _angle.x = _angle.x + (Input.mouse_delta.x * -look_sensitivity);
        _angle.y = _angle.y + (Input.mouse_delta.y * -look_sensitivity);

        // Angle clamp
        if (_angle.y > third_person_min_clamp * C_DEG2RAD)
            _angle.y = third_person_min_clamp * C_DEG2RAD;
        else if (_angle.y < third_person_max_clamp * C_DEG2RAD)
            _angle.y = third_person_max_clamp * C_DEG2RAD;

        // CAMDATA zoom
        // _target_dist -= (mouseWheelMove * CAMERA_MOUSE_SCROLL_SENSITIVITY);

        // CAMDATA distance clamp
        if (_target_dist < third_person_dist)
            _target_dist = third_person_dist;

        // TODO: It seems CAMDATA.position is not correctly updated or some rounding issue makes the CAMDATA move straight to target.transform.position...
        npos_x = sin(_angle.x) * _target_dist * cos(_angle.y) + target.transform.position.x;

        if (_angle.y <= 0.0f)
            npos_y = sin(_angle.y) * _target_dist * sin(_angle.y) + target.transform.position.y;
        else
            npos_y = -sin(_angle.y) * _target_dist * sin(_angle.y) + target.transform.position.y;

        npos_z = cos(_angle.x) * _target_dist * cos(_angle.y) + target.transform.position.z;

        transform.position = Vector3(npos_x, npos_y, npos_z);
    }
}
