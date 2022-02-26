/** scene camera */

module re.ng.camera.base;

import re.ecs;

/// base for SceneCamera2D and SceneCamera3D
abstract class SceneCamera : Component {
    mixin Reflect;
    
    void update() {
    }
}
