#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;

// Output fragpix_coordnt color
out vec4 finalColor;

// user vars
uniform vec2 c_resolution;
uniform float outline_diag; // = 8.;
uniform float outline_div; // = 8.;
uniform float outline_lighten ; //= 0.1;

#define T(u)                                                                   \
  texelFetch(texture0, clamp(ivec2(u), ivec2(0), ivec2(c_resolution.xy) - 1), 0)

void main() {
  float x = fragTexCoord.x * c_resolution.x;
  float y = fragTexCoord.y * c_resolution.y;
  vec2 pix_coord = vec2(x, y);

  vec4 p = T(pix_coord);

  float c = dot(
    abs(T(pix_coord + vec2(0., 1.)) - p) + abs(T(pix_coord + vec2(1., 0.)) - p),
        vec4(outline_diag))
      / outline_div;

  // clamp outline
  float clamped_outline = clamp(c, 0., 1.);

  finalColor = p;
  // blend in the outline
  finalColor = finalColor + (outline_lighten - clamped_outline);
}