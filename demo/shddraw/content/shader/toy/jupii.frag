#ifdef GL_ES
precision mediump float;
#endif

float rand(vec2 co, float seed){
    return fract(sin(dot(co.xy + seed ,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 makeJupiter(vec2 uv)
{
    float time = iTime;
	float timeScale = .5;
	vec2 zoom = vec2(20.,5.5);
	vec2 offset = vec2(2.,1.);

    
    vec2 point = uv * zoom + offset;
  float p_x = float(point.x);
  float p_y = float(point.y);

  // detail levels of swirl bands
  float a_x = .2;
  float a_y = .3;

  // compute iterations to get fractal waves
  for (int i = 1; i < int(10); i++) {
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

  return rgbcol;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
 {
	vec2 resolution = iResolution.xy;
	vec2 texCoord = gl_FragCoord.xy / resolution.xy;
	texCoord = vec2(texCoord.y,texCoord.x);
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	
	vec2 center = resolution.xy / 2.;
	float dis = distance(center, gl_FragCoord.xy);
	float radius = resolution.y / 3.;
	vec3 atmosphereColor = vec3(.7, .6, .5);
	if (dis < radius) {
		// Find planet coordinates
		vec2 posOnPlanet = (gl_FragCoord.xy - (center - radius));
		vec2 planetCoord = posOnPlanet / (radius * 2.0);
		
		// Spherify it
		planetCoord = planetCoord * 2.0 - 1.0;
		float sphereDis = length(planetCoord);
		sphereDis = 1.0 - pow(1.0 - sphereDis, .6);
		planetCoord = normalize(planetCoord) * sphereDis;
		planetCoord = (planetCoord + 1.0) / 2.0;
		
		// Calculate light amounts
		float light = pow(planetCoord.x, 2.0*(cos(iTime*.1 +1.)+1.5));
		float lightAtmosphere = pow(planetCoord.x, 2.);
		
		// Apply light
		vec3 surfaceColor = makeJupiter(texCoord);
		surfaceColor *= light;
		
		// Atmosphere
		float fresnelIntensity = pow(dis / radius, 3.);
		vec3 fresnel = mix(surfaceColor, atmosphereColor, fresnelIntensity * lightAtmosphere);
		
		fragColor = vec4(fresnel.rgb, 1);
        fragColor *= texCoord.x * 2.;
	}
	else {
		// Render stars
		float starAmount = rand(gl_FragCoord.xy, 0.0);
		vec3 background = vec3(0, 0, 0);
		if (starAmount < .01) {
			float intensity = starAmount * 1000.0 / 4.0;
			intensity = clamp(intensity, .1, .3);
			background = vec3(intensity);
		}
		
		// Atmosphere on top
		float outter = distance(center, gl_FragCoord.xy) / resolution.y;
		outter = 1.0 - outter;
		outter = clamp(outter, 0.5, 0.8);
		outter = (outter - .5) / .3;
		outter = pow(outter, 2.8);
		//outter *= texCoord.x * 1.5;
		
		// Add atmosphere on top
		fragColor = vec4(background + atmosphereColor * outter, 1);
	}
}
