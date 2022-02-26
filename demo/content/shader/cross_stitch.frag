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

#define T(u) texelFetch(tex, ivec2(pix_coord), 0);

// shader vars
// uniform float stitch_mix;
float stitch_mix = 0.1;
vec2 stitch_scale = vec2(0.1, 0.1);
// float stitch_size = 6.0;
float stitch_size = 6.0;
int invert = 0;

vec4 frag_shader(sampler2D tex, vec2 frag_coord) {
  vec2 uv = frag_coord / i_resolution.xy;

  vec4 c = vec4(0.0);
  vec2 c_pos = uv * i_resolution.xy * stitch_scale;
  vec2 tlPos = floor(c_pos / vec2(stitch_size, stitch_size));
  tlPos *= stitch_size;

  int remX = int(mod(c_pos.x, stitch_size));
  int remY = int(mod(c_pos.y, stitch_size));

  if (remX == 0 && remY == 0)
    tlPos = c_pos;

  vec2 blPos = tlPos;
  blPos.y += (stitch_size - 1.0);

  if ((remX == remY) ||
      (((int(c_pos.x) - int(blPos.x)) == (int(blPos.y) - int(c_pos.y))))) {
    if (invert == 1)
      c = vec4(0.2, 0.15, 0.05, 1.0);
    else
      c = texture(tex, tlPos * vec2(1.0 / (i_resolution.x * stitch_scale.x),
                                    1.0 / (i_resolution.y * stitch_scale.y))) *
          1.4;
  } else {
    if (invert == 1)
      c = texture(tex, tlPos * vec2(1.0 / (i_resolution.x * stitch_scale.x),
                                    1.0 / (i_resolution.y * stitch_scale.y))) *
          1.4;
    else
      c = vec4(0.0, 0.0, 0.0, 1.0);
  }

  vec4 texelColor = texture(tex, uv) * colDiffuse * fragColor;
  vec3 tc = c.rgb;
  vec4 fx_col = vec4(tc, 1.0);

  return mix(texelColor, fx_col, stitch_mix);
}

void main() {
  vec2 frag_coord = fragTexCoord.xy * i_resolution.xy;
  vec4 draw_col = frag_shader(texture0, frag_coord);

  finalColor = draw_col;
}
