/*
    ASCII SHADER
    Ported to rengfx/GLSL from: https://www.shadertoy.com/view/4ll3RB
*/

#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord; in vec4 fragColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;

// Output fragment color
out vec4 finalColor;

// user vars
uniform vec2 c_resolution;
#define zoom 1.

const float color_adjust_mix = 1;
const float glyph_mix = 1;

// char calculation
#define P(id, a, b, c, d, e, f, g, h) if (id == int(pos.y)) { int pa = a + 2 * (b + 2 * (c + 2 * (d + 2 * (e + 2 * (f + 2 * (g + 2 * (h))))))); cha = floor(mod(float(pa) / pow(2., float(pos.x) - 1.), 2.)); }

float calc_gray(vec3 col) {
    return col.x * 0.299 + col.y * 0.587 + col.z * 0.114;
}

vec4 image_shader(sampler2D source_tex, vec2 pix_coord) {
    // sample based on character width and height
    float samp_x = floor((pix_coord.x / 8.) / zoom) * 8. * zoom;
    float samp_y = floor((pix_coord.y / 12.) / zoom) * 12. * zoom;

    vec2 uv = vec2(samp_x, samp_y) / c_resolution;
    ivec2 pos = ivec2(mod(pix_coord.x / zoom, 8.), mod(pix_coord.y / zoom, 12.));
    vec4 samp_col = texture(source_tex, uv);
    float cha = 0.;

    float g = calc_gray(samp_col.xyz);
    if (g < .125) {
        P(11, 0, 0, 0, 0, 0, 0, 0, 0);
        P(10, 0, 0, 0, 0, 0, 0, 0, 0);
        P(9, 0, 0, 0, 0, 0, 0, 0, 0);
        P(8, 0, 0, 0, 0, 0, 0, 0, 0);
        P(7, 0, 0, 0, 0, 0, 0, 0, 0);
        P(6, 0, 0, 0, 0, 0, 0, 0, 0);
        P(5, 0, 0, 0, 0, 0, 0, 0, 0);
        P(4, 0, 0, 0, 0, 0, 0, 0, 0);
        P(3, 0, 0, 0, 0, 0, 0, 0, 0);
        P(2, 0, 0, 0, 0, 0, 0, 0, 0);
        P(1, 0, 0, 0, 0, 0, 0, 0, 0);
        P(0, 0, 0, 0, 0, 0, 0, 0, 0);
    } else if (g < .25) // .
    {
        P(11, 0, 0, 0, 0, 0, 0, 0, 0);
        P(10, 0, 0, 0, 0, 0, 0, 0, 0);
        P(9, 0, 0, 0, 0, 0, 0, 0, 0);
        P(8, 0, 0, 0, 0, 0, 0, 0, 0);
        P(7, 0, 0, 0, 0, 0, 0, 0, 0);
        P(6, 0, 0, 0, 0, 0, 0, 0, 0);
        P(5, 0, 0, 0, 0, 0, 0, 0, 0);
        P(4, 0, 0, 0, 1, 1, 0, 0, 0);
        P(3, 0, 0, 0, 1, 1, 0, 0, 0);
        P(2, 0, 0, 0, 0, 0, 0, 0, 0);
        P(1, 0, 0, 0, 0, 0, 0, 0, 0);
        P(0, 0, 0, 0, 0, 0, 0, 0, 0);
    } else if (g < .375) // ,
    {
        P(11, 0, 0, 0, 0, 0, 0, 0, 0);
        P(10, 0, 0, 0, 0, 0, 0, 0, 0);
        P(9, 0, 0, 0, 0, 0, 0, 0, 0);
        P(8, 0, 0, 0, 0, 0, 0, 0, 0);
        P(7, 0, 0, 0, 0, 0, 0, 0, 0);
        P(6, 0, 0, 0, 0, 0, 0, 0, 0);
        P(5, 0, 0, 0, 0, 0, 0, 0, 0);
        P(4, 0, 0, 0, 1, 1, 0, 0, 0);
        P(3, 0, 0, 0, 1, 1, 0, 0, 0);
        P(2, 0, 0, 0, 0, 1, 0, 0, 0);
        P(1, 0, 0, 0, 1, 0, 0, 0, 0);
        P(0, 0, 0, 0, 0, 0, 0, 0, 0);
    } else if (g < .5) // -
    {
        P(11, 0, 0, 0, 0, 0, 0, 0, 0);
        P(10, 0, 0, 0, 0, 0, 0, 0, 0);
        P(9, 0, 0, 0, 0, 0, 0, 0, 0);
        P(8, 0, 0, 0, 0, 0, 0, 0, 0);
        P(7, 0, 0, 0, 0, 0, 0, 0, 0);
        P(6, 1, 1, 1, 1, 1, 1, 1, 0);
        P(5, 0, 0, 0, 0, 0, 0, 0, 0);
        P(4, 0, 0, 0, 0, 0, 0, 0, 0);
        P(3, 0, 0, 0, 0, 0, 0, 0, 0);
        P(2, 0, 0, 0, 0, 0, 0, 0, 0);
        P(1, 0, 0, 0, 0, 0, 0, 0, 0);
        P(0, 0, 0, 0, 0, 0, 0, 0, 0);
    } else if (g < .625) // +
    {
        P(11, 0, 0, 0, 0, 0, 0, 0, 0);
        P(10, 0, 0, 0, 0, 0, 0, 0, 0);
        P(9, 0, 0, 0, 1, 0, 0, 0, 0);
        P(8, 0, 0, 0, 1, 0, 0, 0, 0);
        P(7, 0, 0, 0, 1, 0, 0, 0, 0);
        P(6, 1, 1, 1, 1, 1, 1, 1, 0);
        P(5, 0, 0, 0, 1, 0, 0, 0, 0);
        P(4, 0, 0, 0, 1, 0, 0, 0, 0);
        P(3, 0, 0, 0, 1, 0, 0, 0, 0);
        P(2, 0, 0, 0, 0, 0, 0, 0, 0);
        P(1, 0, 0, 0, 0, 0, 0, 0, 0);
        P(0, 0, 0, 0, 0, 0, 0, 0, 0);
    } else if (g < .75) // *
    {
        P(11, 0, 0, 0, 0, 0, 0, 0, 0);
        P(10, 0, 0, 0, 1, 0, 0, 0, 0);
        P(9, 1, 0, 0, 1, 0, 0, 1, 0);
        P(8, 0, 1, 0, 1, 0, 1, 0, 0);
        P(7, 0, 0, 1, 1, 1, 0, 0, 0);
        P(6, 0, 0, 0, 1, 0, 0, 0, 0);
        P(5, 0, 0, 1, 1, 1, 0, 0, 0);
        P(4, 0, 1, 0, 1, 0, 1, 0, 0);
        P(3, 1, 0, 0, 1, 0, 0, 1, 0);
        P(2, 0, 0, 0, 1, 0, 0, 0, 0);
        P(1, 0, 0, 0, 0, 0, 0, 0, 0);
        P(0, 0, 0, 0, 0, 0, 0, 0, 0);
    } else if (g < .875) // #
    {
        P(11, 0, 0, 0, 0, 0, 0, 0, 0);
        P(10, 0, 0, 1, 0, 0, 1, 0, 0);
        P(9, 0, 0, 1, 0, 0, 1, 0, 0);
        P(8, 1, 1, 1, 1, 1, 1, 1, 0);
        P(7, 0, 0, 1, 0, 0, 1, 0, 0);
        P(6, 0, 0, 1, 0, 0, 1, 0, 0);
        P(5, 0, 1, 0, 0, 1, 0, 0, 0);
        P(4, 0, 1, 0, 0, 1, 0, 0, 0);
        P(3, 1, 1, 1, 1, 1, 1, 1, 0);
        P(2, 0, 1, 0, 0, 1, 0, 0, 0);
        P(1, 0, 1, 0, 0, 1, 0, 0, 0);
        P(0, 0, 0, 0, 0, 0, 0, 0, 0);
    } else // @
    {
        P(11, 0, 0, 0, 0, 0, 0, 0, 0);
        P(10, 0, 0, 1, 1, 1, 1, 0, 0);
        P(9, 0, 1, 0, 0, 0, 0, 1, 0);
        P(8, 1, 0, 0, 0, 1, 1, 1, 0);
        P(7, 1, 0, 0, 1, 0, 0, 1, 0);
        P(6, 1, 0, 0, 1, 0, 0, 1, 0);
        P(5, 1, 0, 0, 1, 0, 0, 1, 0);
        P(4, 1, 0, 0, 1, 0, 0, 1, 0);
        P(3, 1, 0, 0, 1, 1, 1, 1, 0);
        P(2, 0, 1, 0, 0, 0, 0, 0, 0);
        P(1, 0, 0, 1, 1, 1, 1, 1, 0);
        P(0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    // divide color by highest component, has a thresholding effect
    vec3 adjusted_col = samp_col.xyz / max(samp_col.x, max(samp_col.y, samp_col.z));

    // mix the color with the base color
    vec3 col = mix(samp_col.xyz, adjusted_col, color_adjust_mix);
    
    // apply the character glyph
    vec3 char_col = mix(col, cha * col, glyph_mix);

    return vec4(char_col, 1.);
}

void main() {
    vec2 pix_coord = fragTexCoord.xy * c_resolution;

    finalColor = image_shader(texture0, pix_coord);
}