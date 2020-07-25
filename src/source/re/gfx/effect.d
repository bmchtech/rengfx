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
        } else {
            static assert(0, "unrecognized shader value data type");
        }
        raylib.SetShaderValue(shader, loc, &data, val_type);
    }
}
