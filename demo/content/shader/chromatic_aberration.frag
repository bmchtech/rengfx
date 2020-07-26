#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;

// Output fragment color
out vec4 finalColor;

// NOTE: Add here your custom variables
uniform vec2 aberrationOffset;

vec4 sample(vec2 offset) {
    return texture(texture0, fragTexCoord.xy - offset) * fragColor;
}

void main() {
    // sample colors

    vec4 texel_r = sample(-aberrationOffset);
    vec4 texel_g = sample(vec2(0, 0));
    vec4 texel_b = sample(aberrationOffset);

    // final frag color
    finalColor = vec4(texel_r.r, texel_g.g, texel_b.b, texel_g.a);
}