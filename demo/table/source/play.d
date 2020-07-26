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
    private PostProcessor glitch_postproc;
    private float[2] aberrationOffset = [0.01, 0];

    override void on_start() {
        clear_color = Colors.LIGHTGRAY;

        // load a shader effect and add it as a postprocessor
        auto chrm_abr = Effect(Core.content.load_shader(null,
                "chromatic_aberration.frag"), color_alpha_white(0.8));
        chrm_abr.set_shader_var("aberrationOffset", aberrationOffset);
        glitch_postproc = new PostProcessor(resolution, chrm_abr);
        postprocessors ~= glitch_postproc;

        // set the camera position
        cam.entity.position = Vector3(0, 10, 10);

        auto fox = create_entity("fox", Vector3(0, 0, 0));
        auto fox_asset = Core.content.load_model("models/fox.obj");
        auto fox_model = fox.add_component(new Model3D(fox_asset));

        // point the camera at the block, then orbit it
        cam.look_at(fox);
        cam.entity.add_component(new CameraOrbit(fox, 0.2));

        // draw a grid at the origin
        auto grid = create_entity("grid");
        grid.add_component(new Grid3D(20, 1));
    }
}
