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
    private raylib.Camera2D _camera;

    this() {
        _camera = raylib.Camera2D();
    }

    override void setup() {
        // defaults
        _camera.offset = Vector2(entity.scene.resolution.x / 2, entity.scene.resolution.y / 2);
        _camera.zoom = 1;
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

class CameraFollow2D : Component, Updatable {
    /// the target entity to follow
    public Entity target;
    public float lerp;

    this(Entity target, float lerp) {
        this.target = target;
        this.lerp = lerp;
    }

    void update() {
        // get vector to target
        auto to_target = target.position2 - entity.position2;
        auto scroll = Vector2(to_target.x * lerp, to_target.y * lerp);
        entity.position2 = entity.position2 + scroll;
    }
}
