module play;

import re;
import re.gfx;
import re.gfx.shapes.model;
import re.gfx.shapes.grid;
import re.ng.camera;
import re.math;
static import raylib;

/// simple 3d demo scene
class PlayScene : Scene3D {
    override void on_start() {
        clear_color = Colors.BLACK;

        // set the camera position
        cam.entity.position = Vector3(10, 12, 10);

        auto thing = create_entity("thing", Vector3(0, 0, 0));
        auto thing_asset = Core.content.load_model("models/fountain3.glb");
        auto thing_model = thing.add_component(new Model3D(thing_asset));
        thing_model.transform.scale = Vector3(4, 4, 4);
        thing_model.transform.orientation = Vector3(C_PI_2, 0, 0); // euler angles

        // add a camera to look at the thing
        cam.entity.add_component(new CameraOrbit(thing, 0.5));
        // cam.entity.add_component(new CameraFreeLook(thing));
    }

    override void update() {
        super.update();

        if (Input.is_mouse_pressed(MouseButton.MOUSE_LEFT_BUTTON)) {
            if (Input.is_cursor_locked) {
                Input.unlock_cursor();
            } else {
                Input.lock_cursor();
            }
        }
    }
}
