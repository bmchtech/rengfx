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
uniform float bokeh_base;       // = .005;
uniform float bokeh_maxv;       // = 1000.;
uniform float bokeh_focus_dist; // = 5.;

#define Tf(u)                                                                  \
  texelFetch(texture0, clamp(ivec2(u), ivec2(0), ivec2(i_resolution.xy) - 1), 0)

vec4 image_shader(sampler2D tex, vec2 pix_coord) {
  vec4 o = vec4(0);
  float d = bokeh_base *
            (clamp(Tf(pix_coord).w, .0, bokeh_maxv) - bokeh_focus_dist) *
            i_resolution.y;
  float s = 10., a, n = 0.;
  for (float r = 0.; r < 1.; r += 1. / s) {
    for (float i = 0.; i < 1.; i += 1. / (s * r), n++) {
      a = i * radians(360.);
      vec2 s_adj = vec2(cos(a), sin(a)) * r;
      vec2 loc = pix_coord + s_adj * d;
      o += clamp(Tf(loc), 0., 1.);
    }
  }
  o /= n;
  o = pow(o, vec4(1. / 2.2)); // brighten

  return o;
}

void main() {
  vec2 pix_coord = fragTexCoord.xy * i_resolution.xy;

  finalColor = image_shader(texture0, pix_coord);
}