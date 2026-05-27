#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float iTime;
    int rand;
};

layout(binding = 1) uniform sampler2D source1;
layout(binding = 2) uniform sampler2D source2;

const float PI = 3.141592653589793;
const float strength = 0.3;

float Linear_ease(in float begin, in float change, in float duration, in float time)
{
    return change*time/duration+begin;
}
float Exponential_easeInOut(in float begin, in float change, in float duration, in float time) 
{
    if(time == 0) return begin;
    else if(time == duration) return begin+change;
    time = time/(duration/2);
if(time<1) return change/2*pow(2, 10*(time-1))+begin;
    else return change/2*(-pow(2, -10*(time-1))+2)+begin;
}
float Sinusoidal_easeInOut(in float begin, in float change, in float duration, in float time)
{
    return -change/2*(cos(PI*time/duration)-1)+begin;
}
float random(in vec3 scale, in float seed)
{
    return fract(sin(dot(gl_FragCoord.xyz+seed, scale)) * 43758.5453 + seed);
}
vec3 crossFade(in vec2 uv, in float dissolve)
{
    return mix(texture(source1, uv).rgb, texture(source2, uv).rgb, dissolve);
}
void main()
{
    float progress = sin(iTime*PI/6)*2;

    vec2 center = vec2(Linear_ease(0.5, 0, 1, progress), 0.5);
    float dissolve = Exponential_easeInOut(0, 1, 1, progress);
    float strength = Sinusoidal_easeInOut(0, strength, 0.5, progress);

    vec3 color = vec3(0);
    float total = 0;
    vec2 toCenter = center - qt_TexCoord0;

    float offset = random(vec3(12.9898, 78.233, 151.7182), 0)*0.5;
    
    for(float t=0; t<=20; t++)
    {
        float percent = (t+offset)/20;
        float weight = (1-percent)*percent;
        color += crossFade(qt_TexCoord0+toCenter*percent*strength, dissolve)*weight;
        total += weight;
    }
    fragColor = vec4(color/total, 1);
}
