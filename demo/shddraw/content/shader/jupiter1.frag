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

#define T(u) texelFetch(tex, ivec2(pix_coord), 0);

/** custom shader code */

float iteration = 10.;
float timeScale = 3.;
vec2 zoom = vec2(25., 5.5);
vec2 offset = vec2(0, 2.);

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
  float time = i_time;
  vec2 point = uv * zoom + offset;
  float p_x = float(point.x);
  float p_y = float(point.y);

  float a_x = .2;
  float a_y = .3;

  for (int i = 1; i < int(iteration); i++) {
    float float_i = float(i);
    point.x += a_x * sin(float_i * point.y + time * timeScale);
    point.y += a_y * cos(float_i * point.x);
  }

  float r = sin(point.y) * .5 + .4;
  float g = cos(point.y) * .5 + .7;
  float b = cos(point.y) * .5 + .8;

  r += .3;

  r = cos(point.x + point.y + 1.3) * .5 + .5;
  g = sin(point.x + point.y + 2.) * .5 + .5;
  b = (sin(point.x + point.y + 1.) + cos(point.x + point.y + 1.)) * .25 + .5;

  r = pow(r, .8);
  g = pow(g, .8);
  b = pow(b, 1.);

  vec3 col = vec3(r, g, b);
  col += vec3(.1);

  return col;
}

vec2 seeCoords(vec2 p) { return p.xy; }

vec2 arrangeCoords(vec2 p) {
  vec2 q = p.xy / i_resolution.xy;
  vec2 r = -1.0 + 2.0 * q;
  r.x *= i_resolution.x / i_resolution.y;
  return r;
}

vec4 draw(sampler2D tex, vec2 frag_coord) {
  vec2 p = arrangeCoords(frag_coord);

  vec3 lookAt = vec3(0.);
  vec3 camPos = vec3(5. * sin(i_time * 0.3), 3., -4. * cos(i_time * 0.3));
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
  ivec2 pix_coord = ivec2(fragTexCoord.xy * i_resolution.xy);
  vec2 frag_coord = fragTexCoord.xy * i_resolution.xy;

  // draw
  vec4 draw_col = draw(texture0, frag_coord);

  finalColor = draw_col;
}