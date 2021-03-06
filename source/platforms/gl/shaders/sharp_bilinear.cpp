//
// Created by cpasjuste on 17/09/18.
//

const char *sharp_bilinear_v = R"text(

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
    COMPAT_ATTRIBUTE vec4 VertexCoord;
    COMPAT_ATTRIBUTE vec4 COLOR;
    COMPAT_ATTRIBUTE vec4 TexCoord;
    //layout (location = 0) in vec4 VertexCoord;
    //layout (location = 1) in vec4 COLOR;
    //layout (location = 2) in vec4 TexCoord;
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

    // vertex compatibility #defines
    #define vTexCoord TEX0.xy
    #define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
    #define outsize vec4(OutputSize, 1.0 / OutputSize)

    COMPAT_VARYING vec2 precalc_texel;
    COMPAT_VARYING vec2 precalc_scale;

    void main()
    {
        // CROSS2D
        // gl_Position = MVPMatrix * VertexCoord;
        gl_Position = projectionMatrix * (modelViewMatrix * vec4(VertexCoord.x, VertexCoord.y, 0.0, 1.0));
        COL0 = COLOR;
        // CROSS2D
        // TEX0.xy = TexCoord.xy;
        TEX0 = textureMatrix * vec4(VertexCoord.x, VertexCoord.y, 0.0, 1.0);

        precalc_texel = vTexCoord * SourceSize.xy;
        precalc_scale = max(floor(outsize.xy / InputSize.xy), vec2(1.0, 1.0));
    }

)text";

const char *sharp_bilinear_f = R"text(

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

    // fragment compatibility #defines
    #define Source Texture
    #define vTexCoord TEX0.xy

    #define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
    #define outsize vec4(OutputSize, 1.0 / OutputSize)

    COMPAT_VARYING COMPAT_PRECISION vec2 precalc_texel;
    COMPAT_VARYING COMPAT_PRECISION vec2 precalc_scale;

    void main()
    {
       COMPAT_PRECISION vec2 texel = precalc_texel;
       COMPAT_PRECISION vec2 scale = precalc_scale;

       COMPAT_PRECISION vec2 texel_floored = floor(texel);
       COMPAT_PRECISION vec2 s = fract(texel);
       COMPAT_PRECISION vec2 region_range = 0.5 - 0.5 / scale;

       // Figure out where in the texel to sample to get correct pre-scaled bilinear.
       // Uses the hardware bilinear interpolator to avoid having to sample 4 times manually.

       COMPAT_PRECISION vec2 center_dist = s - 0.5;
       COMPAT_PRECISION vec2 f = (center_dist - clamp(center_dist, -region_range, region_range)) * scale + 0.5;

       COMPAT_PRECISION vec2 mod_texel = texel_floored + f;

       fragColor = vec4(COMPAT_TEXTURE(Source, mod_texel / SourceSize.xy).rgb, 1.0);
    }
)text";
