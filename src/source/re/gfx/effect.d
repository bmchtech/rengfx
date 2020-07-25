module re.gfx.effect;

import re.gfx.raytypes;

/// represents an effect
struct Effect {
    /// the shader program for the effect
    Shader shader;
    /// the tint color
    Color color;
}