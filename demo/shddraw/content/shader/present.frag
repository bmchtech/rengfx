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

#define T(u) texelFetch(tex, ivec2(pix_coord), 0);

vec4 frag_shader(sampler2D tex, ivec2 pix_coord) {
  vec4 base = T(pix_coord);

  return base;
}

void main() {
  ivec2 pix_coord = ivec2(fragTexCoord.xy * i_resolution.xy);
  vec2 frag_coord = fragTexCoord.xy * i_resolution.xy;

  vec4 draw_col = frag_shader(texture0, pix_coord);

  finalColor = draw_col;
}