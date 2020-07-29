module re.ng.camera.cam2d;

import re.ecs;
import re.time;
import re.math;
import re.ng.camera.base;
import re.gfx.raytypes;
import std.math;
static import raylib;

/// represents a camera for a 2D scene
class SceneCamera2D : SceneCamera {
    mixin Reflect;
    private raylib.Camera2D _camera;

    this() {
        _camera = raylib.Camera2D();
    }

    override void setup() {
        // defaults
        _camera.zoom = 1;
    }

    @property ref raylib.Camera2D camera() return  {
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
        _camera.rotation = entity.transform.rotation_z;
        _camera.zoom = entity.transform.scale.x;
    }
}

class CameraFollow2D : Component, Updatable {
    mixin Reflect;
    // private SceneCamera2D cam;
    /// the target entity to follow
    public Entity target;
    public float lerp;

    this(Entity target, float lerp) {
        this.target = target;
        this.lerp = lerp;
    }

    override void setup() {
        auto cam = entity.get_component!SceneCamera2D();
        // set offset to half-resolution (so that our target is centered)
        cam.offset = Vector2(entity.scene.resolution.x / 2, entity.scene.resolution.y / 2);
    }

    void update() {
        // get vector to target
        auto to_target = target.position2 - entity.position2;
        auto scroll = Vector2(to_target.x * lerp, to_target.y * lerp);
        entity.position2 = entity.position2 + scroll;
    }
}
