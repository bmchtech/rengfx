module re.gfx.vr;

import re;
import re.math;
import re.gfx;
import std.format;

static import raylib;

version (vr) class VRSupport {
    /// whether VR is enabled
    public bool enabled = false;
    public raylib.VrStereoConfig config;
    public raylib.Shader distortion_shader;

    /// set up VR rendering
    public void setup_vr(raylib.VrDeviceInfo device_info) {
        enabled = true;

        config = raylib.LoadVrStereoConfig(device_info);

        Core.log.info(format("initializing vr stereo config for device: %s", device_info));

        // // update render resolution
        // resolution = Vector2(device_info.hResolution, device_info.vResolution);

        import re.util.vr_distortion;
        import re.util.interop : c_str;

        // set up distortion shader
        // auto distortion_shader = LoadShader(0, TextFormat("resources/distortion%i.fs", GLSL_VERSION));
        distortion_shader = raylib.LoadShaderFromMemory(null, VR_DISTORTION_SHADER_GL330
                .c_str);

        // set shader vars
        alias vartype = raylib.ShaderUniformDataType;
        // Update distortion shader with lens and distortion-scale parameters
        raylib.SetShaderValue(distortion_shader, raylib.GetShaderLocation(distortion_shader, "leftLensCenter"),
            cast(float*) config.leftLensCenter, vartype.SHADER_UNIFORM_VEC2);
        raylib.SetShaderValue(distortion_shader, raylib.GetShaderLocation(distortion_shader, "rightLensCenter"),
            cast(float*) config.rightLensCenter, vartype.SHADER_UNIFORM_VEC2);
        raylib.SetShaderValue(distortion_shader, raylib.GetShaderLocation(distortion_shader, "leftScreenCenter"),
            cast(float*) config.leftScreenCenter, vartype.SHADER_UNIFORM_VEC2);
        raylib.SetShaderValue(distortion_shader, raylib.GetShaderLocation(distortion_shader, "rightScreenCenter"),
            cast(float*) config.rightScreenCenter, vartype.SHADER_UNIFORM_VEC2);

        raylib.SetShaderValue(distortion_shader, raylib.GetShaderLocation(distortion_shader, "scale"),
            cast(float*) config.scale, vartype.SHADER_UNIFORM_VEC2);
        raylib.SetShaderValue(distortion_shader, raylib.GetShaderLocation(distortion_shader, "scaleIn"),
            cast(float*) config.scaleIn, vartype.SHADER_UNIFORM_VEC2);
        raylib.SetShaderValue(distortion_shader, raylib.GetShaderLocation(distortion_shader, "deviceWarpParam"),
            cast(float*) device_info.lensDistortionValues, vartype.SHADER_UNIFORM_VEC4);
        raylib.SetShaderValue(distortion_shader, raylib.GetShaderLocation(distortion_shader, "chromaAbParam"),
            cast(float*) device_info.chromaAbCorrection, vartype.SHADER_UNIFORM_VEC4);
    }
}
