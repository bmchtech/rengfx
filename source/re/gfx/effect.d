module re.gfx.effect;

import std.string : toStringz;

import re.gfx.raytypes;
import re.util.hotreload;
static import raylib;

/// represents an effect
class Effect {
    /// the shader program for the effect
    Shader shader;
    /// the tint color
    Color color;
    /// a reloadable shader if any
    ReloadableShader reloadable_shader;

    this() {
        this(Shader.init);
    }

    this(Shader shader, Color color = Colors.WHITE) {
        this.shader = shader;
        this.color = color;
    }

    this(ReloadableShader reloadable_shader, Color color = Colors.WHITE) {
        this.reloadable_shader = reloadable_shader;
        auto shader = reloadable_shader.reload();
        this(shader, color);
    }

    public void update() {
        // update the effect
        // if hot reload is enabled
        if (reloadable_shader) {
            // check if we need to reload the shader
            if (reloadable_shader.changed()) {
                // shader changed, we load it again
                shader = reloadable_shader.reload();
            }
        }
    }

    /// set a uniform value to an immeditae value
    public bool set_shader_var_imm(T)(string name, T value) {
        T var = value;
        return set_shader_var(name, var);
    }

    /// set a uniform value to a variable by reference
    public bool set_shader_var(T)(string name, ref T value) {
        auto loc = get_shader_loc(name);
        if (loc < 0) {
            // if the shader variable doesn't exist, return false
            return false;
        }

        // figure out the uniform var type
        raylib.ShaderUniformDataType val_type;
        alias vartype = raylib.ShaderUniformDataType;
        static if (is(T == float)) {
            val_type = vartype.SHADER_UNIFORM_FLOAT;
        } else static if (is(T == int)) {
            val_type = vartype.SHADER_UNIFORM_INT;
        } else static if (is(T == float[2])) {
            val_type = vartype.SHADER_UNIFORM_VEC2;
        } else static if (is(T == float[3])) {
            val_type = vartype.SHADER_UNIFORM_VEC3;
        } else static if (is(T == float[4])) {
            val_type = vartype.SHADER_UNIFORM_VEC4;
        } else static if (is(T == int[2])) {
            val_type = vartype.SHADER_UNIFORM_IVEC2;
        } else static if (is(T == int[3])) {
            val_type = vartype.SHADER_UNIFORM_IVEC3;
        } else static if (is(T == int[4])) {
            val_type = vartype.SHADER_UNIFORM_IVEC4;
        } else {
            static assert(0, "unrecognized shader value data type");
        }
        raylib.SetShaderValue(shader, loc, &value, val_type);
        return true;
    }

    /// get location of uniform in shader. returns -1 if not found
    public int get_shader_loc(string name) {
        return raylib.GetShaderLocation(shader, name.toStringz);
    }
}
