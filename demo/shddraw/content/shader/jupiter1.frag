// shader based on
// https://raw.githubusercontent.com/lunasorcery/Blossom/main/blossom/draw.frag

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

/** custom shader code */
/**
    jupiter
    based on https://www.shadertoy.com/view/MdyfWw
*/

float iteration = 10.;
float timeScale = 3.;
vec2 zoom = vec2(25., 5.5);
vec2 offset = vec2(0, 2.);

vec3 rgb2hsv(vec3 c) {
  vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
  vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
  vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

  float d = q.x - min(q.w, q.y);
  float e = 1.0e-10;
  return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float sdSphere(vec3 p, float s) { return length(p) - s; }

vec2 scene(in vec3 pos) // reception d'une sphere
{
  vec3 dim = vec3(1, 1, 1);

  pos += vec3(0, 0., 0);

  float resSphere = sdSphere(pos, 1.3);

  vec2 res = vec2(resSphere, 2.);

  return res;
}

vec3 calcNormal(in vec3 pos) {
  vec3 eps = vec3(0.001, 0.0, 0.0);
  vec3 nor = vec3(scene(pos + eps.xyy).x - scene(pos - eps.xyy).x,
                  scene(pos + eps.yxy).x - scene(pos - eps.yxy).x,
                  scene(pos + eps.yyx).x - scene(pos - eps.yyx).x);
  return normalize(nor);
}

vec2 getUV(vec3 pos) {
  vec3 nor = calcNormal(pos);
  float lon = atan(nor.x, nor.z) / 3.14;
  float lat = acos(nor.y) / 3.14;
  vec2 r = vec2(lat, lon);

  return r;
}

vec2 rayMarching(in vec3 camPos, in vec3 rayDirection) {
  float dMin = 1.;
  float dMax = 50.;
  float precis = 0.002;
  float traveledDistance = dMin;
  float color = -1.;

  for (int i = 0; i < 50; i++) {
    vec2 res = scene(camPos + (rayDirection * traveledDistance));

    if (res.x < precis || traveledDistance > dMax) {
      break;
    }

    traveledDistance += res.x;
    color = res.y;
  }

  if (traveledDistance > dMax) {
    color = -1.0;
  }
  return vec2(traveledDistance, color);
}

mat3 setCamera(in vec3 ro, in vec3 ta, float cr) {
  vec3 cw = normalize(ta - ro);          // z (dir)
  vec3 cp = vec3(sin(cr), cos(cr), 0.0); // haut
  vec3 cu = normalize(cross(cw, cp));    // x (droite/gauche)
  vec3 cv = normalize(cross(cu, cw));    // y (haut normalisÃ©)
  return mat3(cu, cv, cw);
}

vec3 makeJupiter(vec2 uv) {
  float time = iTime;

  // uv offset
  vec2 point = uv * zoom + offset;
  float p_x = float(point.x);
  float p_y = float(point.y);

  // detail levels of swirl bands
  float a_x = .2;
  float a_y = .3;

  // compute iterations to get fractal waves
  for (int i = 1; i < int(iteration); i++) {
    float float_i = float(i);
    point.x += a_x * sin(float_i * point.y + time * timeScale);
    point.y += a_y * cos(float_i * point.x);
  }

  // colors from point positions
  float pr = cos(point.x + point.y + 1.3);
  float pg = sin(point.x + point.y + 2.0);
  float pb = (sin(point.x + point.y + 0.9) + cos(point.x + point.y + 0.9));

  // linear transform of colors
  float r = pr * .40 + .50;
  float g = pg * .40 + .36;
  float b = pb * .25 + .20;

  // recurve colors intensity
  r = pow(r, .98);
  g = pow(g, .91);
  b = pow(b, .88);

  // create color from rgb
  vec3 rgbcol = vec3(r, g, b);
  rgbcol += vec3(.1);

  // transform to hsv for adjustments
  vec3 hsvcol = rgb2hsv(rgbcol);
  hsvcol.y *= 0.85;
  hsvcol.z *= 0.90;

  // return rgb color
  return hsv2rgb(hsvcol);
}

vec2 seeCoords(vec2 p) { return p.xy; }

vec2 arrangeCoords(vec2 p) {
  vec2 q = p.xy / iResolution.xy;
  vec2 r = -1.0 + 2.0 * q;
  r.x *= iResolution.x / iResolution.y;
  return r;
}

vec4 draw(sampler2D tex, vec2 frag_coord) {
  vec2 p = arrangeCoords(frag_coord);

  vec3 lookAt = vec3(0.);
  vec3 camPos = vec3(5. * sin(iTime * 0.3), 3., -4. * cos(iTime * 0.3));
  camPos = vec3(2, 2.1, 2.);

  mat3 camera = setCamera(camPos, lookAt, 0.);

  vec3 rayDirection = camera * normalize(vec3(p.xy, 2.0));
  vec2 rayResult = rayMarching(camPos, rayDirection);

  float rayDistance = rayResult.x;
  float rayColor = rayResult.y;
  vec3 hitPos = camPos + rayDirection * rayDistance;
  vec2 chekerUv;

  vec3 color;

  vec3 sphereColor = vec3(0, 0, 0);

  if (rayColor > 1.) {
    color = vec3(1., 0.4, 0.1);

    if (rayDistance > 1.) {
      chekerUv = getUV(hitPos);
      // sphereColor = vec3(makeCheker(chekerUv));
      sphereColor = vec3(makeJupiter(chekerUv));
      // sphereColor = vec3(seeCoords(chekerUv), 0.);
    }
  } else {
    color = vec3(0., 0., 0.);
  }

  vec3 pos = camPos + rayDistance * rayDirection;
  vec3 nor = calcNormal(pos);

  return vec4(sphereColor, 1);
}

void main() {
  // set up coordinates
  ivec2 pix_coord = ivec2(fragTexCoord.xy * iResolution.xy);
  vec2 frag_coord = fragTexCoord.xy * iResolution.xy;

  // draw
  vec4 draw_col = draw(texture0, frag_coord);

  finalColor = draw_col;
}