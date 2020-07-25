module re.gfx.raytypes;

// raylib types
static import raylib;

public {
    import raylib : Color, Colors, Image, Texture2D;
    import raylib : Mesh, Model, Shader;

    alias RenderTarget = raylib.RenderTexture2D;
}

// - utility functions

pragma(inline) {
    /// gets a color that is white with a given alpha
    public Color color_alpha_white(float alpha) {
        return raylib.ColorFromNormalized(raylib.Vector4(1, 1, 1, alpha));
    }

    /// gets a color from floats
    public Color color_alpha_white(float r, float g, float b, float a = 1) {
        return raylib.ColorFromNormalized(raylib.Vector4(r, g, b, a));
    }

    /// fades a color
    public Color color_fade(Color color, float fade) {
        return raylib.Fade(color, fade);
    }

    /// gets a color from hsv
    public Color color_hsv(float h, float s, float v) {
        return raylib.ColorFromHSV(h, s, v);
    }
}
