#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;

// Output fragment color
out vec4 finalColor;

// user vars
// uniform float c_threshold;
uniform vec2 c_resolution;
// uniform vec4 c_outline_color;

#define T(u)                                                                   \
  texelFetch(texture0, clamp(ivec2(u), ivec2(0), ivec2(c_resolution.xy) - 1), 0)
// #define T(u)
// texelFetch(iChannel0,clamp(ivec2(u),ivec2(0),ivec2(iResolution.xy)-1),0)

void main() {
  float x = fragTexCoord.x * c_resolution.x;
  float y = fragTexCoord.y * c_resolution.y;
  vec2 pix_coord = vec2(x, y);

  float bokeh_base = .005;
  float bokeh_maxv = 1000.;
  float bokeh_focus_dist = 5.;

  bool bokeh_enable = true;

  if (bokeh_enable) {
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
  } else {
    finalColor = T(pix_coord);
  }

  float outline_diag = 1.;
  float outline_div = 8.;
  float outline_lighten = 0.1;

  vec2 me = vec2(pix_coord);
  vec4 p = T(me);

  float c = dot(abs(T(me + vec2(0., 1.)) - p) + abs(T(me + vec2(1., 0.)) - p),
                vec4(outline_diag)) /
            outline_div;

  // mouse position controls the divider (2 is half)
  // float mouse_divider = 1. / (iMouse.x / c_resolution.x);
  float mouse_divider = 1 / 0.5;

  // clamp outline
  float clamped_outline = clamp(c, 0., 1.);

  if (pix_coord.x * mouse_divider > c_resolution.x) {
    finalColor = p;
    // blend in the outline
    finalColor = finalColor + (outline_lighten - clamped_outline);
    // finalColor = vec4(clamped_outline); // preview the outline
  }
  // finalColor = p;
  // // blend in the outline
  // finalColor = finalColor + (outline_lighten - clamped_outline);
}