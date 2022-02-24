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
float timeScale = 0.8;
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

float rand(vec2 co, float seed) {
  return fract(sin(dot(co.xy + seed, vec2(12.9898, 78.233))) * 43758.5453);
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
  vec4 frag_col = vec4(0.0);

  vec2 resolution = iResolution.xy;
  vec2 texCoord = frag_coord.xy / resolution.xy;
  texCoord.xy = texCoord.yx;
  vec2 position = (frag_coord.xy / resolution.xy);

  vec2 center = resolution.xy / 2.;
  float dis = distance(center, frag_coord.xy);
  float radius = resolution.y / 3.;
  vec3 atmosphereColor = vec3(.7, .6, .5);
  if (dis < radius) {
    // Find planet coordinates
    vec2 posOnPlanet = (frag_coord.xy - (center - radius));
    vec2 planetCoord = posOnPlanet / (radius * 2.0);

    // Spherify it
    planetCoord = planetCoord * 2.0 - 1.0;
    float sphereDis = length(planetCoord);
    sphereDis = 1.0 - pow(1.0 - sphereDis, .6);
    planetCoord = normalize(planetCoord) * sphereDis;
    planetCoord = (planetCoord + 1.0) / 2.0;

    // Calculate light amounts
    float light = pow(planetCoord.x, 2.0 * (cos(iTime * .1 + 1.) + 1.5));
    float lightAtmosphere = pow(planetCoord.x, 2.);

    // Apply light
    vec3 surfaceColor = makeJupiter(texCoord);
    surfaceColor *= light;

    // Atmosphere
    float fresnelIntensity = pow(dis / radius, 3.);
    vec3 fresnel =
        mix(surfaceColor, atmosphereColor, fresnelIntensity * lightAtmosphere);

    frag_col = vec4(fresnel.rgb, 1);
    // frag_col *= texCoord.x * 2.;
  } else {
    // Render stars
    float starAmount = rand(frag_coord.xy, 0.0);
    vec3 background = vec3(0, 0, 0);
    if (starAmount < .01) {
      float intensity = starAmount * 1000.0 / 4.0;
      intensity = clamp(intensity, .1, .3);
      background = vec3(intensity);
    }

    // Atmosphere on top
    float outter = distance(center, frag_coord.xy) / resolution.y;
    outter = 1.0 - outter;
    outter = clamp(outter, 0.5, 0.8);
    outter = (outter - .5) / .3;
    outter = pow(outter, 2.8);
    // outter *= texCoord.x * 1.5;

    // Add atmosphere on top
    frag_col = vec4(background + atmosphereColor * outter, 1);
  }

  return frag_col;
}

void main() {
  // set up coordinates
  ivec2 pix_coord = ivec2(fragTexCoord.xy * iResolution.xy);
  vec2 frag_coord = fragTexCoord.xy * iResolution.xy;

  // draw
  vec4 draw_col = draw(texture0, frag_coord);

  finalColor = draw_col;
}