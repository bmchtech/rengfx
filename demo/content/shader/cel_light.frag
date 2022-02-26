#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;

// Output fragment color
out vec4 finalColor;

// user vars
uniform vec3 i_resolution;
uniform int i_frame;
uniform float i_time;

// shadertoy compat
#define iResolution i_resolution
#define iFrame i_frame
#define iTime i_time

// #define T(u) texelFetch(tex, ivec2(pix_coord), 0);

// shader vars
uniform float outline_diag;    // = 8.;
uniform float outline_div;     // = 8.;
uniform float outline_lighten; //= 0.1;

#define Tf(u)                                                                  \
  texelFetch(texture0, clamp(ivec2(u), ivec2(0), ivec2(i_resolution.xy) - 1), 0)

vec4 image_shader(sampler2D tex, vec2 pix_coord) {
  vec4 p = Tf(pix_coord);

  float c = dot(abs(Tf(pix_coord + vec2(0., 1.)) - p) +
                    abs(Tf(pix_coord + vec2(1., 0.)) - p),
                vec4(outline_diag)) /
            outline_div;

  // clamp outline
  float clamped_outline = clamp(c, 0., 1.);

  vec4 col = p;
  // blend in the outline
  col += (outline_lighten - clamped_outline);

  return col;
}

void main() {
  vec2 pix_coord = fragTexCoord.xy * i_resolution.xy;

  finalColor = image_shader(texture0, pix_coord);
}