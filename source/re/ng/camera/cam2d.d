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
