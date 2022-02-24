#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;

// Output fragment color
out vec4 finalColor;

// user vars
uniform vec2 c_resolution;
uniform float bokeh_base;       // = .005;
uniform float bokeh_maxv;       // = 1000.;
uniform float bokeh_focus_dist; // = 5.;

#define T(u)                                                                   \
  texelFetch(texture0, clamp(ivec2(u), ivec2(0), ivec2(c_resolution.xy) - 1), 0)

void main() {
  float x = fragTexCoord.x * c_resolution.x;
  float y = fragTexCoord.y * c_resolution.y;
  vec2 pix_coord = vec2(x, y);

  vec4 o = vec4(0);
  float d = bokeh_base *
            (clamp(T(pix_coord).w, .0, bokeh_maxv) - bokeh_focus_dist) *
            c_resolution.y;
  float s = 10., a, n = 0.;
  for (float r = 0.; r < 1.; r += 1. / s) {
    for (float i = 0.; i < 1.; i += 1. / (s * r), n++) {
      a = i * radians(360.);
      vec2 s_adj = vec2(cos(a), sin(a)) * r;
      vec2 loc = pix_coord + s_adj * d;
      o += clamp(T(loc), 0., 1.);
    }
  }
  o /= n;
  o = pow(o, vec4(1. / 2.2)); // brighten
  finalColor = o;
}