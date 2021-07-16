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
    const int CAPTURE_FRAMECOUNT = 10;
    const int CAPTURE_FRAMESKIP = 6;

    int start_frame;
    Image[] captured_frames;

    override void on_start() {
        clear_color = Colors.BLACK;

        start_frame = Time.frame_count;

        // set the camera position
        cam.entity.position = Vector3(10, 12, 10);

        auto thing = create_entity("thing", Vector3(0, 0, 0));
        auto thing_asset = Core.content.load_model("models/fountain3.glb");
        auto thing_model = thing.add_component(new Model3D(thing_asset));
        thing_model.transform.scale = Vector3(4, 4, 4);
        thing_model.transform.orientation = Vector3(C_PI_2, 0, 0); // euler angles

        // add a camera to look at the thing
        cam.entity.add_component(new CameraOrbit(thing, 2.0));
        // cam.entity.add_component(new CameraFreeLook(thing));
    }

    override void update() {
        super.update();

        immutable int frame_num = Time.frame_count - start_frame;
        if (captured_frames.length < CAPTURE_FRAMECOUNT) {
            if (frame_num % CAPTURE_FRAMESKIP == 0) {
                // capture frame data
                auto frame = raylib.GetScreenData();

                // correct for capture (is upside down??)

                raylib.ImageFlipVertical(&frame);
                // raylib.ImageFlipHorizontal(&frame);
                captured_frames ~= frame;
            }
        } else {
            // done capturing
            auto target = raylib.LoadRenderTexture(cast(int) resolution.x * CAPTURE_FRAMECOUNT,
                    cast(int) resolution.y);

            raylib.BeginTextureMode(target);
            raylib.BeginDrawing();

            for (int i = 0; i < CAPTURE_FRAMECOUNT; i++) {
                auto tex = raylib.LoadTextureFromImage(captured_frames[i]);
                raylib.DrawTexture(tex, i * cast(int) resolution.x, 0, Colors.WHITE);
            }

            raylib.EndDrawing();
            raylib.EndTextureMode();

            auto target_img = raylib.GetTextureData(target.texture);
            raylib.ExportImage(target_img, "captures.png");

            // TODO: unload everything

            Core.exit();
        }

        if (Input.is_mouse_pressed(MouseButton.MOUSE_LEFT_BUTTON)) {
            if (Input.is_cursor_locked) {
                Input.unlock_cursor();
            } else {
                Input.lock_cursor();
            }
        }
    }
}
