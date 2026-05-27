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

float gridWidth = 28, gridHeight = 15.0;

void main()
{
    vec2 uv = qt_TexCoord0;
    float fadeTimer = iTime*2+0.55;

    vec2 posI = vec2(uv.x*gridWidth*2, uv.y*gridHeight*2);
    vec2 pos = mod(posI, 2) - vec2(1, 1);

    posI = vec2(floor(posI.x/2)/gridWidth, floor(posI.y/2)/gridHeight);
    
    float size;
    // 3 types
    switch(rand%3) {
        case 0: size = pow(fadeTimer - posI.y, 3); break;
        case 1: size = pow(fadeTimer - posI.x, 3); break;
        case 2: size = pow(fadeTimer - abs(posI.x-0.5) - abs(posI.y-0.5), 3); break;
    }
    size = abs(size);

    if(abs(pos.x)+abs(pos.y)<size)
        fragColor = texture(source2, uv);
    else
        fragColor = texture(source1, uv);
}
