#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;

// Output fragment color
out vec4 finalColor;

// user vars
uniform float c_threshold;
uniform vec2 c_resolution;

vec4 sample_at(vec2 pos) { return texture(texture0, pos / c_resolution.xy); }

float sample_x_at(float x, float y) { return sample_at(vec2(x, y)).x; }

void main() {
  float x = fragTexCoord.x * c_resolution.x;
  float y = fragTexCoord.y * c_resolution.y;

  float xValue = -sample_x_at(x - 1.0, y - 1.0) -
                 2.0 * sample_x_at(x - 1.0, y) - sample_x_at(x - 1.0, y + 1.0) +
                 sample_x_at(x + 1.0, y - 1.0) + 2.0 * sample_x_at(x + 1.0, y) +
                 sample_x_at(x + 1.0, y + 1.0);

  float yValue = sample_x_at(x - 1.0, y - 1.0) + 2.0 * sample_x_at(x, y - 1.0) +
                 sample_x_at(x + 1.0, y - 1.0) - sample_x_at(x - 1.0, y + 1.0) -
                 2.0 * sample_x_at(x, y + 1.0) - sample_x_at(x + 1.0, y + 1.0);

  if (length(vec2(xValue, yValue)) > c_threshold) {
    finalColor = vec4(0, 0, 0, 1);
  } else {
    vec4 currentPixel = texture(texture0, fragTexCoord);
    finalColor = currentPixel;
  }
}