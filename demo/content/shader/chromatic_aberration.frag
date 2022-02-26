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
uniform vec2 sample_offset;
// vec2 sample_offset = vec2(0.005, 0.01);
// #define bean 0

vec4 sample(vec2 offset) {
  return texture(texture0, fragTexCoord.xy - offset) * fragColor;
}

vec4 frag_shader(sampler2D tex, vec2 frag_coord) {
  // sample colors
  vec2 uv = frag_coord / i_resolution.xy;

  // vec4 texel_r = texture(tex, uv - sample_offset) * fragColor;
  // vec4 texel_g = texture(tex, uv) * fragColor;
  // vec4 texel_b = texture(tex, uv + sample_offset) * fragColor;

  vec4 texel_r = sample(-sample_offset);
  vec4 texel_g = sample(vec2(0, 0));
  vec4 texel_b = sample(sample_offset);

  return vec4(texel_r.r, texel_g.g, texel_b.b, texel_g.a);
}

void main() {
  vec2 frag_coord = fragTexCoord.xy * i_resolution.xy;
  vec4 draw_col = frag_shader(texture0, frag_coord);

  finalColor = draw_col;
}