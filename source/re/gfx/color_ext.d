module re.gfx.color_ext;

import re.gfx.raytypes;
import re.math;
import std.math;
static import raylib;

// - color functions

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
        return raylib.ColorFromHSV(Vector3(h, s, v));
    }

    /// gets a color from rgb
    public Color color_rgb(float r, float g, float b, float a = 1.0) {
        return raylib.ColorFromNormalized(Vector4(r, g, b, a));
    }

    /// gets a color from rgb
    public Color color_rgb(ubyte r, ubyte g, ubyte b, ubyte a = 255) {
        return Color(r, g, b, 255);
    }

    /// gets a color from rgb in a single value
    public Color color_rgb(ubyte v) {
        return color_rgb(v, v, v);
    }
}

/// color blending algorithm - from https://stackoverflow.com/a/39924008/13240621
public Color color_blend(Color c1, Color c2, float mix) {
    // Mix [0..1]
    //  0   --> all c1
    //  0.5 --> equal mix of c1 and c2
    //  1   --> all c2

    // Invert sRGB gamma compression
    c1 = inverse_srgb_companding(c1);
    c2 = inverse_srgb_companding(c2);

    Color result;
    result.r = cast(ubyte)(c1.r * (1 - mix) + c2.r * (mix));
    result.g = cast(ubyte)(c1.g * (1 - mix) + c2.g * (mix));
    result.b = cast(ubyte)(c1.b * (1 - mix) + c2.b * (mix));

    // Reapply sRGB gamma compression
    result = srgb_companding(result);

    return result;
}

private Color inverse_srgb_companding(Color c) {
    // Convert color from 0..255 to 0..1
    float r = c.r / 255;
    float g = c.g / 255;
    float b = c.b / 255;

    // Inverse Red, Green, and Blue
    if (r > 0.04045)
        r = pow((r + 0.055) / 1.055, 2.4);
    else
        r = r / 12.92;
    if (g > 0.04045)
        g = pow((g + 0.055) / 1.055, 2.4);
    else
        g = g / 12.92;
    if (b > 0.04045)
        b = pow((b + 0.055) / 1.055, 2.4);
    else
        b = b / 12.92;

    // Convert 0..1 back into 0..255
    Color result;
    result.r = cast(ubyte)(r * 255);
    result.g = cast(ubyte)(g * 255);
    result.b = cast(ubyte)(b * 255);

    return result;
}

private Color srgb_companding(Color c) {
    // Convert color from 0..255 to 0..1
    float r = c.r / 255;
    float g = c.g / 255;
    float b = c.b / 255;

    // Apply companding to Red, Green, and Blue
    if (r > 0.0031308)
        r = 1.055 * pow(r, 1 / 2.4) - 0.055;
    else
        r = r * 12.92;
    if (g > 0.0031308)
        g = 1.055 * pow(g, 1 / 2.4) - 0.055;
    else
        g = g * 12.92;
    if (b > 0.0031308)
        b = 1.055 * pow(b, 1 / 2.4) - 0.055;
    else
        b = b * 12.92;

    // Convert 0..1 back into 0..255
    Color result;
    result.r = cast(ubyte)(r * 255);
    result.g = cast(ubyte)(g * 255);
    result.b = cast(ubyte)(b * 255);

    return result;
}
