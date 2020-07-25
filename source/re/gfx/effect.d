module re.gfx.effect;

import re.gfx.raytypes;
static import raylib;

/// represents an effect
struct Effect {
    /// the shader program for the effect
    Shader shader;
    /// the tint color
    Color color;

    public void set_shader_var(T)(string name, ref T value) {
        import std.string : toStringz;

        auto loc = raylib.GetShaderLocation(shader, name.toStringz);
        raylib.ShaderUniformDataType val_type;
        alias vartype = raylib.ShaderUniformDataType;
        static if (is(T == float)) {
            val_type = vartype.UNIFORM_FLOAT;
        } else static if (is(T == int)) {
            val_type = vartype.UNIFORM_INT;
        } else static if (is(T == float[2])) {
            val_type = vartype.UNIFORM_VEC2;
        } else static if (is(T == float[3])) {
            val_type = vartype.UNIFORM_VEC3;
        } else static if (is(T == float[4])) {
            val_type = vartype.UNIFORM_VEC4;
        } else static if (is(T == int[2])) {
            val_type = vartype.UNIFORM_IVEC2;
        } else static if (is(T == int[3])) {
            val_type = vartype.UNIFORM_IVEC3;
        } else static if (is(T == int[4])) {
            val_type = vartype.UNIFORM_IVEC4;
        } else {
            static assert(0, "unrecognized shader value data type");
        }
        raylib.SetShaderValue(shader, loc, &value, val_type);
    }
}
