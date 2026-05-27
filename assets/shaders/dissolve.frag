#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float iTime;
};

layout(binding = 1) uniform sampler2D source1;
layout(binding = 2) uniform sampler2D source2;

float FadeSpeed = 1.5;

void main()
{
    vec2 uv = qt_TexCoord0;

    vec4 tex1 = texture(source1, uv);
    vec4 tex2 = texture(source2, uv);

    float t = clamp(sin(iTime * FadeSpeed), 0.0, 1.0);

    fragColor = mix(tex1, tex2, t) * qt_Opacity;
}
