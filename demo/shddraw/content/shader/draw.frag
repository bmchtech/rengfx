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

/* vvv your shader goes here vvv */

const float pi = acos(-1.);

mat2 rotate(float b) {
  float c = cos(b);
  float s = sin(b);
  return mat2(c, -s, s, c);
}

float sdOctahedron(vec3 p, float r) {
  return (dot(abs(p), vec3(1)) - r) / sqrt(3.);
}

float shape(vec3 p) {
  float d = sdOctahedron(p, 1.5);
  p.y = abs(p.y) - .15;
  d = max(d, -sdOctahedron(p, 1.5));
  return d;
}

// space-repeating macro
vec3 rep(vec3 a, float b) { return mod(a - b, b + b) - b; }

// sdf describing the scene geometry
float scene(vec3 p) {
  float d = 1e9;
  float R = 4.;

  for (int i = 0; i < 3; ++i) {
    d = min(d, shape(rep(p + vec3(R, 0, R), R)));
    d = min(d, shape(rep(p + vec3(0, R, 0), R)));
    p = p.yzx;
  }

  return d;
}

// hash functions adapted from Devour
// https://www.shadertoy.com/view/3llSzM
float seed;
float hash() {
  float p = fract((seed++) * .1031);
  p += (p * (p + 19.19)) * 3.;
  return fract((p + p) * p);
}
vec2 hash2() { return vec2(hash(), hash()); }

void main() {
  // seed the RNG (again taken from Devour)
  seed = float(((i_frame * 73856093) ^ int(gl_FragCoord.x) * 19349663 ^
                int(gl_FragCoord.y) * 83492791) %
               38069);

  // set up UVs, jittered for antialiasing
  //   vec2 uv = (gl_FragCoord.xy + hash2() - .5) / i_resolution.xy - .5;
  //   uv.x *= i_resolution.z;
  vec2 uv = ((gl_FragCoord.xy - .5) / i_resolution.xy) - .5;

  // mess with UVs for a fun wide-angle lens
  uv *= 4. + length(uv);

  // create a camera
  vec3 cam = vec3(0, 0, -10);
  vec3 dir = normalize(vec3(uv, 1));

  // a bit of diamond-shaped bokeh
  vec2 bokehOffset = (hash2() - .5) * rotate(pi * .25);
  const float dofScale = .5;
  const float focusDistance = 17.;
  cam.xy += bokehOffset * dofScale;
  dir.xy -= bokehOffset * dofScale / focusDistance;

  // spin the camera
  cam.yz *= rotate(atan(1., sqrt(2.)));
  dir.yz *= rotate(atan(1., sqrt(2.)));
  cam.xz *= rotate(pi * .75);
  dir.xz *= rotate(pi * .75);

  // background color
  vec3 color = vec3(.2 * (length(uv)), .1, .25);

  //   // raymarcher loop
  //   const float epsilon = .001;
  //   float t = 0.;
  //   float k = 0.;
  //   for (int i = 0; i < 200; ++i) {
  //     k = scene(cam + dir * t);
  //     if (abs(k) < epsilon)
  //       break;
  //     t += k;
  //   }

  //   // surface shading
  //   if (abs(k) < epsilon) {
  //     vec3 h = cam + dir * t;
  //     vec2 o = vec2(epsilon, 0);
  //     vec3 n = normalize(
  //         vec3(scene(h + o.xyy), scene(h + o.yxy), scene(h + o.yyx)) - k);

  //     float light = dot(n, normalize(vec3(1, 2, 3))) * .35 + .65;

  //     float fog = min(1., pow(.9, t - 20.));
  //     color = mix(color, vec3(light), fog);
  //   }

  finalColor = vec4(color, 1);
}

// vec4 draw(sampler2D tex, ivec2 pix_coord) {
//   vec4 base = T(pix_coord);

//   //   float fade = (i_frame / 100.0);
//   float fade = i_time / 2;
//   fade = clamp(fade, 0.0, 1.0);
//   vec3 col_shade = vec3(0.9, 0.7, 0.5) * fade;
//   vec4 col = vec4(col_shade.rgb, 1.0);
//   return col;
// }

// void main() {
//   ivec2 pix_coord = ivec2(fragTexCoord.xy / i_resolution.xy);
//   vec2 uv = fragTexCoord.xy / i_resolution.xy;
//   vec4 draw_col = draw(texture0, pix_coord);
//   finalColor = draw_col;
// }