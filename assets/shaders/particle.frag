#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float iTime;   // 0~1
    int rand;
    vec2 resolution;
};

layout(binding = 1) uniform sampler2D source1;
layout(binding = 2) uniform sampler2D source2;

const float particleSize = 45.0;
const float density = 0.45;
const float rotationRange = 30.0 / 180.0 * 3.1415926;
const float travelDistanceRatio = 1.0;

float hash(vec2 p)
{
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

vec2 rotate(vec2 v, float a)
{
    float c = cos(a);
    float s = sin(a);
    return vec2(v.x*c - v.y*s, v.x*s + v.y*c);
}

float quadraticInOut(float t)
{
    float p = 2.0*t*t;
    return t < 0.5 ? p : -p + 4.0*t - 1.0;
}

void main()
{
    vec2 fragCoord = qt_TexCoord0 * resolution;

    float t = iTime;
    float st = quadraticInOut(t);

    float travelDistance = (resolution.x + resolution.y) * travelDistanceRatio;
    float fx = travelDistance;

    vec3 cameraPos = vec3(resolution * 0.5,
                          -fx + travelDistance * 0.8 * st);

    float phi0 = rotationRange * st;

    // background (correct)
    vec2 uv = fragCoord - resolution * 0.5;
    vec2 rotUV = rotate(uv, -phi0) / resolution + 0.5;

    vec3 bg = mix(
        texture(source1, rotUV).rgb,
        texture(source2, fragCoord / resolution).rgb,
        st
    );

    vec4 sum = vec4(0.0);
    float wsum = 0.0;

    // ❗ IMPORTANT: full grid BUT capped
    int numX = min(int(resolution.x / particleSize), 120);
    int numY = min(int(resolution.y / particleSize), 80);

    for(int i = 0; i < numX; i++)
    for(int j = 0; j < numY; j++)
    {
        vec2 coordp = vec2(i,j) * particleSize;

        float h = hash(coordp + float(rand));
        if(h > density) continue;

        float noise = hash(coordp * 1.7);

        vec3 pos0 = vec3(
            coordp + 30.0*noise,
            -(travelDistance * noise) * st * 0.5
        );

        vec3 sp = pos0 - cameraPos;

        if(sp.z <= 0.0) continue;

        // rotate
        sp.xy = rotate(sp.xy, phi0);

        sp.xy = sp.xy * fx / sp.z;
        sp.xy += resolution * 0.5;

        float radius = particleSize * fx / sp.z;

        vec2 d = fragCoord - sp.xy;
        float r = length(d) / radius;

        if(r < 1.0)
        {
            vec3 c0 = texture(source1, pos0.xy / resolution).rgb;
            vec3 c1 = texture(source2, pos0.xy / resolution).rgb;

            vec3 col = mix(c0, c1, st);

            sum += vec4(col, 1.0);
            wsum += 1.0;

            if(wsum > 10.0) break; // ❗ clamp influence
        }
    }

    vec3 particle = (wsum > 0.0)
        ? sum.rgb / wsum
        : vec3(0.0);

    float coverage = step(0.0001, wsum);

    float w;
    if(t < 0.2) w = smoothstep(0.0,0.2,t);
    else if(t < 0.8) w = 1.0;
    else w = 1.0 - smoothstep(0.8,1.0,t);

    vec3 finalColor = mix(bg, particle, w * coverage);

    fragColor = vec4(finalColor, 1.0) * qt_Opacity;
}
