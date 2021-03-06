//
// Created by cpasjuste on 17/09/18.
//

const char *lcd3x_v = R"text(

    // Parameter lines go here:
    #pragma parameter brighten_scanlines "Brighten Scanlines" 16.0 1.0 32.0 0.5
    #pragma parameter brighten_lcd "Brighten LCD" 4.0 1.0 12.0 0.1

#if __VERSION__ >= 130
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#define COMPAT_TEXTURE texture
#define COMPAT_PRECISION
#else
// assume opengl es...
#define COMPAT_VARYING varying
#define COMPAT_ATTRIBUTE attribute
#define COMPAT_TEXTURE texture2D
#define COMPAT_PRECISION mediump
#endif

    // CROSS2D
    COMPAT_ATTRIBUTE vec4 positionAttribute;
    COMPAT_ATTRIBUTE vec4 colorAttribute;
    COMPAT_ATTRIBUTE vec4 texCoordAttribute;
    uniform mat4 modelViewMatrix;
    uniform mat4 projectionMatrix;
    uniform mat4 textureMatrix;
    // CROSS2D
    COMPAT_VARYING vec4 COL0;
    COMPAT_VARYING vec4 TEX0;

    uniform mat4 MVPMatrix;
    uniform COMPAT_PRECISION int FrameDirection;
    uniform COMPAT_PRECISION int FrameCount;
    uniform COMPAT_PRECISION vec2 OutputSize;
    uniform COMPAT_PRECISION vec2 TextureSize;
    uniform COMPAT_PRECISION vec2 InputSize;

    void main()
    {
        // CROSS2D
        // gl_Position = MVPMatrix * positionAttribute;
        gl_Position = projectionMatrix * (modelViewMatrix * vec4(positionAttribute.x, positionAttribute.y, 0.0, 1.0));
        COL0 = colorAttribute;
        // CROSS2D
        // TEX0.xy = TexCoord.xy;
        TEX0 = textureMatrix * vec4(texCoordAttribute.x, texCoordAttribute.y, 0.0, 1.0);
    }
)text";

const char *lcd3x_f = R"text(

    // Parameter lines go here:
    #pragma parameter brighten_scanlines "Brighten Scanlines" 16.0 1.0 32.0 0.5
    #pragma parameter brighten_lcd "Brighten LCD" 4.0 1.0 12.0 0.1

#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out vec4 fragColor;
#define COMPAT_PRECISION
#else
// assume opengl es...
#define COMPAT_VARYING varying
#define fragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#define COMPAT_PRECISION mediump
#endif

    uniform COMPAT_PRECISION int FrameDirection;
    uniform COMPAT_PRECISION int FrameCount;
    uniform COMPAT_PRECISION vec2 OutputSize;
    uniform COMPAT_PRECISION vec2 TextureSize;
    uniform COMPAT_PRECISION vec2 InputSize;
    uniform sampler2D Texture;
    COMPAT_VARYING COMPAT_PRECISION vec4 TEX0;

    // compatibility #defines
    #define Source Texture
    #define vTexCoord TEX0.xy

    #define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
    #define outsize vec4(OutputSize, 1.0 / OutputSize)

    #ifdef PARAMETER_UNIFORM
    // All parameter floats need to have COMPAT_PRECISION in front of them
    uniform COMPAT_PRECISION float brighten_scanlines;
    uniform COMPAT_PRECISION float brighten_lcd;
    #else
    #define brighten_scanlines 16.0
    #define brighten_lcd 4.0
    #endif

    const COMPAT_PRECISION vec3 offsets = vec3(3.141592654) * vec3(1.0/2.0,1.0/2.0 - 2.0/3.0,1.0/2.0-4.0/3.0);

    void main()
    {
        COMPAT_PRECISION vec2 omega = vec2(3.141592654) * vec2(2.0) * SourceSize.xy;
        COMPAT_PRECISION vec3 res = COMPAT_TEXTURE(Source, vTexCoord).xyz;

        COMPAT_PRECISION vec2 angle = vTexCoord * omega;

        COMPAT_PRECISION float yfactor = (brighten_scanlines + sin(angle.y)) / (brighten_scanlines + 1.0);
        COMPAT_PRECISION vec3 xfactors = (brighten_lcd + sin(angle.x + offsets)) / (brighten_lcd + 1.0);

        COMPAT_PRECISION vec3 color = yfactor * xfactors * res;

        fragColor = vec4(color.x, color.y, color.z, 1.0);
    }
)text";
