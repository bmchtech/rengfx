module re.gfx.effect;

import re.gfx.raytypes;
import re.math;
static import raylib;

/// represents an effect
struct Effect {
    /// the shader program for the effect
    Shader shader;
    /// the tint color
    Color color;

    public void set_shader_var(T)(string name, T value) {
        import std.string : toStringz;

        auto loc = raylib.GetShaderLocation(shader, name.toStringz);
        raylib.ShaderUniformDataType val_type;
        alias vartype = raylib.ShaderUniformDataType;
        static if (is(T == float)) {
            val_type = vartype.UNIFORM_FLOAT;
            float data = value;
        } else static if (is(T == int)) {
            val_type = vartype.UNIFORM_INT;
            int data = value;
        } else static if (is(T == Vector2)) {
            val_type = vartype.UNIFORM_VEC2;
            float[2] data = [value.x, value.y];
        } else static if (is(T == Vector3)) {
            val_type = vartype.UNIFORM_VEC3;
            float[3] data = [value.x, value.y, value.z];
        } else static if (is(T == Vector4)) {
            val_type = vartype.UNIFORM_VEC4;
            float[4] data = [value.x, value.y, value.z, value.w];
        } else static if (is(T == int[2])) {
            val_type = vartype.UNIFORM_IVEC2;
            int[2] data = [value[0], value[1]];
        } else static if (is(T == int[3])) {
            val_type = vartype.UNIFORM_IVEC3;
            int[3] data = [value[0], value[1], value[2]];
        } else static if (is(T == int[4])) {
            val_type = vartype.UNIFORM_IVEC4;
            int[4] data = [value[0], value[1], value[2], value[3]];
        } else {
            static assert(0, "unrecognized shader value data type");
        }
        raylib.SetShaderValue(shader, loc, &data, val_type);
    }
}
