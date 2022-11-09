/** scene with 3d rendering */

module re.ng.scene3d;

static import raylib;
public import raylib : Camera3D;
import re.ng.camera;
import re;
import re.gfx;
import std.string;
import re.ecs;
import re.math;

/// represents a scene rendered in 3d
abstract class Scene3D : Scene {
    /// the 3d scene camera
    public SceneCamera3D cam;

    version (vr) {
        /// whether VR is enabled
        public bool vr_enabled = false;
        public raylib.VrStereoConfig vr_config;
    }

    override void setup() {
        super.setup();

        // create a camera entity
        auto camera_nt = create_entity("camera");
        cam = camera_nt.add_component(new SceneCamera3D());
    }

    void render_renderable(Component component) {
        auto renderable = cast(Renderable3D) component;
        assert(renderable !is null, "renderable was not 3d");
        renderable.render();
        if (Core.debug_render) {
            renderable.debug_render();
        }
    }

    override void render_scene() {
        version (vr) {
            if (vr_enabled)
                raylib.BeginVrStereoMode(vr_config);
        }

        raylib.BeginMode3D(cam.camera);

        // render 3d components
        foreach (component; ecs.storage.renderable_components) {
            render_renderable(component);
        }
        foreach (component; ecs.storage.updatable_renderable_components) {
            render_renderable(component);
        }

        render_hook();

        raylib.EndMode3D();

        version (vr) {
            if (vr_enabled)
                raylib.EndVrStereoMode();
        }
    }

    override void update() {
        super.update();

        cam.update();
    }

    override void unload() {
        version (vr) {
            if (vr_enabled) {
                assert(vr_config != raylib.VrStereoConfig.init, "vr config was not initialized");

                raylib.UnloadVrStereoConfig(vr_config);
            }

        }

        super.unload();
    }

    version (vr) {
        /// set up VR rendering
        void setup_vr(raylib.VrDeviceInfo vr_device_info) {
            vr_enabled = true;

            vr_config = raylib.LoadVrStereoConfig(vr_device_info);

            Core.log.info(format("initializing vr stereo config for device: %s", vr_device_info));

            // update render resolution
            resolution = Vector2(vr_device_info.hResolution, vr_device_info.vResolution);

            import re.util.vr_distortion;
            import re.util.interop : c_str;

            // set up distortion shader
            // auto distortion_shader = LoadShader(0, TextFormat("resources/distortion%i.fs", GLSL_VERSION));
            auto distortion_shader = raylib.LoadShaderFromMemory(null, VR_DISTORTION_SHADER_GL330
                    .c_str);

            // set shader vars
            alias vartype = raylib.ShaderUniformDataType;
            // Update distortion shader with lens and distortion-scale parameters
            raylib.SetShaderValue(distortion_shader, raylib.GetShaderLocation(distortion_shader, "leftLensCenter"),
                cast(float*) vr_config.leftLensCenter, vartype.SHADER_UNIFORM_VEC2);
            raylib.SetShaderValue(distortion_shader, raylib.GetShaderLocation(distortion_shader, "rightLensCenter"),
                cast(float*) vr_config.rightLensCenter, vartype.SHADER_UNIFORM_VEC2);
            raylib.SetShaderValue(distortion_shader, raylib.GetShaderLocation(distortion_shader, "leftScreenCenter"),
                cast(float*) vr_config.leftScreenCenter, vartype.SHADER_UNIFORM_VEC2);
            raylib.SetShaderValue(distortion_shader, raylib.GetShaderLocation(distortion_shader, "rightScreenCenter"),
                cast(float*) vr_config.rightScreenCenter, vartype.SHADER_UNIFORM_VEC2);

            raylib.SetShaderValue(distortion_shader, raylib.GetShaderLocation(distortion_shader, "scale"),
                cast(float*) vr_config.scale, vartype.SHADER_UNIFORM_VEC2);
            raylib.SetShaderValue(distortion_shader, raylib.GetShaderLocation(distortion_shader, "scaleIn"),
                cast(float*) vr_config.scaleIn, vartype.SHADER_UNIFORM_VEC2);
            raylib.SetShaderValue(distortion_shader, raylib.GetShaderLocation(distortion_shader, "deviceWarpParam"),
                cast(float*) vr_device_info.lensDistortionValues, vartype.SHADER_UNIFORM_VEC4);
            raylib.SetShaderValue(distortion_shader, raylib.GetShaderLocation(distortion_shader, "chromaAbParam"),
                cast(float*) vr_device_info.chromaAbCorrection, vartype.SHADER_UNIFORM_VEC4);

            // distortion_fx.set_shader_var_imm("leftLensCenter", vr_config.leftLensCenter);
            // distortion_fx.set_shader_var_imm("rightLensCenter", vr_config.rightLensCenter);
            // distortion_fx.set_shader_var_imm("leftScreenCenter", vr_config.leftScreenCenter);
            // distortion_fx.set_shader_var_imm("rightScreenCenter", vr_config.rightScreenCenter);

            // distortion_fx.set_shader_var_imm("scale", vr_config.scale);
            // distortion_fx.set_shader_var_imm("scaleIn", vr_config.scaleIn);
            // distortion_fx.set_shader_var_imm("deviceWarpParam", vr_device_info.lensDistortionValues);
            // distortion_fx.set_shader_var_imm("chromaAbParam", vr_device_info.chromaAbCorrection);

            // add postprocessing shader
            auto distortion_fx = new Effect(distortion_shader);
            postprocessors ~= new PostProcessor(resolution, distortion_fx);
        }
    }
}
