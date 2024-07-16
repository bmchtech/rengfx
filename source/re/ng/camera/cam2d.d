/** 2d scene camera */

module re.ng.camera.cam2d;

import re.ecs;
import re.time;
import re.math;
import re.ng.camera.base;
import re.ng.viewport;
import re.gfx.raytypes;
import std.math;
static import raylib;

/// represents a camera for a 2D scene
class SceneCamera2D : SceneCamera {
    mixin Reflect;
    private raylib.Camera2D _camera;

    this() {
        _camera = raylib.Camera2D();
        _camera.offset = Vector2(0, 0);
        _camera.target = Vector2(0, 0);
        _camera.rotation = 0;
        _camera.zoom = 1;
    }

    override void setup() {
        // defaults
        _camera.zoom = 1;
    }

    @property ref raylib.Camera2D camera() return {
        return _camera;
    }

    /// gets the camera offset (displacement from target)
    @property Vector2 offset() {
        return _camera.offset;
    }

    /// sets the camera offset (displacement from target)
    @property Vector2 offset(Vector2 value) {
        return _camera.offset = value;
    }

    override void update() {
        super.update();

        // copy entity to camera transform
        _camera.target = entity.transform.position2;
        _camera.rotation = entity.transform.rotation_z * C_RAD2DEG;
        _camera.zoom = entity.transform.scale.x;
    }
}

class CameraFollow2D : Component, Updatable {
    mixin Reflect;
    public Viewport viewport;
    public Entity target;
    public float lerp;
    private SceneCamera2D cam;
    public bool follow_rotation = false;

    this(Viewport viewport, Entity target, float lerp) {
        this.viewport = viewport;
        this.target = target;
        this.lerp = lerp;
    }

    override void setup() {
        cam = entity.get_component!SceneCamera2D();
    }

    void update() {
        // set offset to half-resolution (so that our target is centered)
        cam.offset = Vector2(viewport.resolution.x / 2, viewport.resolution.y / 2);

        if (follow_rotation) {
            // // lerp towards target rotation
            // auto to_target = target.transform.rotation_z - entity.transform.rotation_z;
            // auto rot_scroll = to_target * lerp;
            // entity.transform.rotation_z = entity.transform.rotation_z + rot_scroll;
            // lock target rotation
            entity.transform.rotation_z = target.transform.rotation_z;
        }

        // get vector to target
        auto to_target = target.position2 - entity.position2;
        // lerp towards target
        auto scroll = Vector2(to_target.x * lerp, to_target.y * lerp);
        entity.position2 = entity.position2 + scroll;
    }
}
