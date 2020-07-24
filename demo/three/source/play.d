module play;

import re;
import re.gfx;
import re.math;

class PlayScene : Scene3D {
    override void on_start() {
        clear_color = Colors.LIGHTGRAY;

        camera.position = Vector3(10, 10, 10);
        camera.target = Vector3(0, 0, 0);
        camera.up = Vector3(0, 1, 0);
        camera.fovy = 45;
        camera.type = CameraType.CAMERA_PERSPECTIVE;

        // TODO: add scene entities
    }
}
