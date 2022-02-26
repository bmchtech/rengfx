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

vec4 frag_shader(sampler2D tex, vec2 frag_coord) {
  // normalized pixel coordinates (from 0 to 1)
  vec2 uv = frag_coord / i_resolution.xy;

  // time varying pixel color
  vec3 col = 0.5 + 0.5 * cos(i_time + uv.xyx + vec3(0, 2, 4));
  return vec4(col, 1.0);
}

void main() {
  vec2 frag_coord = fragTexCoord.xy * i_resolution.xy;
  vec4 draw_col = frag_shader(texture0, frag_coord);

  finalColor = draw_col;
}