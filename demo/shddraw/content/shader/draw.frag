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

#define T(u) texelFetch(tex, ivec2(pix_coord), 0);

vec4 draw(sampler2D tex, ivec2 pix_coord) {
  vec4 base = T(pix_coord);

//   float fade = (i_frame / 100.0);
  float fade = i_time / 2;
  fade = clamp(fade, 0.0, 1.0);
  vec3 col_shade = vec3(0.9, 0.7, 0.5) * fade;
  vec4 col = vec4(col_shade.rgb, 1.0);
  return col;
}

void main() {
  ivec2 pix_coord = ivec2(fragTexCoord.xy / i_resolution.xy);
  vec2 uv = fragTexCoord.xy / i_resolution.xy;
  vec4 draw_col = draw(texture0, pix_coord);
  finalColor = draw_col;
}